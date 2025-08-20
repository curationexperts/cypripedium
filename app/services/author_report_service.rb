# frozen_string_literal: true

class AuthorReportService
  def self.run(...)
    new(...).build_report
  end

  def initialize(start: 2022)
    @start_date = start
    @raw_data = fetch_stats_from_solr(start)
  end

  def build_report
    report  = header_row
    report += total_row
    report += spacer_row
    report += spacer_row('STAFF')
    report += staff_rows
    report += spacer_row
    report += spacer_row('CONSULTANTS')
    report += consultant_rows
    report += spacer_row
    report += spacer_row('OTHERS')
    report + other_rows
  end

  private

  def header_keys
    ['group', 'id', 'name'] + report_periods + ['total']
  end

  def report_periods
    @report_periods ||= document_totals.keys
  end

  def header_row
    [header_keys.index_with { |key| key.titleize }]
  end

  def spacer_row(group = nil)
    [header_keys.index_with { |key| key == 'group' ? group : '' }]
  end

  def total_row
    [{ 'group' => 'TOTAL', 'id' => '', 'name' => 'unique documents' }
       .merge(document_totals)
       .merge('total' => @raw_data['response']['numFound'])]
  end

  def document_totals
    date_created_iti = @raw_data['facet_counts']['facet_fields']['date_created_iti']
    Hash[*date_created_iti]
  end

  def staff_rows
    rows_for(Creator.staff)
  end

  def consultant_rows
    rows_for(Creator.consultant)
  end

  def other_rows
    rows_for(Creator.unassigned)
  end

  # Given an active record scope (of Creators)
  # Creat an array for the included creators ordered by their display name
  def rows_for(creator_scope)
    raw_group = creator_scope.order(:display_name).pluck(:group, :id, :display_name)
    group = raw_group.map { |c| { 'group' => c[0], 'id' => c[1].to_s, 'name' => c[2] } }
    group.map { |c| c.merge(creator_stats[c['id']] || {}) }
  end

  # Re-arrange the Solr pivot factets into a lookup table
  # using the creator id as the lookup key
  # and returning the publication statistics for that creator_id
  def creator_stats
    @creator_stats ||= pivot_counts.map { |creator| [creator['value'].to_s, transform_pivot(creator)] }.to_h
  end

  def pivot_counts
    @pivots ||= @raw_data['facet_counts']['facet_pivot']["creator_id_ssim,date_created_iti"]
  end

  # Transform a pivot facet from the Solr response into a simple
  # year ==> value hash
  def transform_pivot(raw_facet)
    raise "Unexpected field: #{raw_facet['field']}" unless raw_facet['field'] == 'creator_id_ssim'

    creator_row = {}
    creator_row['id'] = raw_facet['value']
    creator_row['total'] = raw_facet['count']
    raw_facet['pivot'].each do |pivot|
      # e.g. creator_row [ year ] = publication count for year
      creator_row[pivot['value'].to_s] = pivot['count']
    end
    creator_row
  end

  # Runs a facet query on creation years (date_created_iti)
  # and a facet pivot on publication counts by creator id and year
  # the only things in the repository with creation years and creator ids
  # are the publications we want to count
  def fetch_stats_from_solr(start)
    solr = Blacklight.default_index.connection
    query = {
      "q" => "date_created_iti:[#{start} TO *]",
      "facet.field" => "date_created_iti",
      "facet.pivot" => "creator_id_ssim,date_created_iti",
      "facet.limit" => "-1",
      "rows" => "0",
      "facet" => "true",
      "facet.sort" => "index"
    }
    solr.get 'select', params: query
  end
end
