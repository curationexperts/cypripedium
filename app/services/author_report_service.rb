# frozen_string_literal: true

class AuthorReportService
  QUARTERS = { '01' => 'Q1', '04' => 'Q2', '07' => 'Q3', '10' => 'Q4' }.freeze
  PERIODS = { 'yearly' => :yearly, 'quarterly' => :quarterly, 'monthly' => :monthly }.with_indifferent_access

  attr_reader :start_date, :period

  def self.run(...)
    new(...).build_report
  end

  def initialize(start: Time.current, period: :yearly)
    @start_date = safe_date(start)
    @period = PERIODS[period] || :yearly
    @raw_data = fetch_stats_from_solr
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
    @header_keys ||= ['group', 'id', 'name'] + report_periods + ['total']
  end

  def header_labels
    ['Group', 'ID', 'Name'] + labels_for_periods + ['Total']
  end

  def labels_for_periods
    case period
    when :yearly
      # 2021
      report_periods.map { |p| p[0..3] }
    when :quarterly
      # 2021 Q2
      report_periods.map { |p| "#{p[0..3]} #{QUARTERS[p[5..6]]}" }
    when :monthly
      # 2021-06
      report_periods.map { |p| p[0..6] }
    end
  end

  def report_periods
    @report_periods ||= document_totals.keys
  end

  def header_row
    [header_keys.zip(header_labels).to_h]
  end

  def spacer_row(group = nil)
    [header_keys.index_with { |key| key == 'group' ? group : nil }]
  end

  def total_row
    [{ 'group' => 'TOTAL', 'id' => nil, 'name' => 'unique documents' }
       .merge(document_totals)
       .merge('total' => @raw_data['response']['numFound'])]
  end

  def document_totals
    date_uploaded = @raw_data['facet_counts']['facet_ranges']['date_uploaded_dtsi']['counts']
    Hash[*date_uploaded]
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
    @raw_data['facet_counts']['facet_pivot']["creator_id_ssim"]
  end

  # Transform a pivot facet from the Solr response into a simple
  # year ==> value hash
  def transform_pivot(raw_facet)
    raise "Unexpected field: #{raw_facet['field']}" unless raw_facet['field'] == 'creator_id_ssim'

    creator_row = {}
    creator_row['id'] = raw_facet['value']
    creator_row['total'] = raw_facet['count']
    counts = raw_facet['ranges']['date_uploaded_dtsi']['counts']
    counts.each_slice(2) do |period, count|
      creator_row[period] = count unless count.zero?
    end
    creator_row
  end

  # Runs a facet query on creation years (date_created_iti)
  # and a facet pivot on publication counts by creator id and year
  # the only things in the repository with creation years and creator ids
  # are the publications we want to count
  def fetch_stats_from_solr
    solr = Blacklight.default_index.connection
    query = {
      "fq" => ["date_created_iti:[#{start_year} TO *]",
               "date_uploaded_dtsi:[#{start_date} TO *]"],
      "facet.range" => "{!tag=r1}date_uploaded_dtsi",
      "facet.range.start" => start_date,
      "facet.range.end" => now_iso,
      "facet.range.gap" => gap_for_solr,
      "facet.pivot" => "{!range=r1}creator_id_ssim",
      "rows" => "0",
      "facet" => "true",
      "facet.mincount" => "0",
      "facet.limit" => "-1",
      "facet.sort" => "index"
    }
    solr.get 'select', params: query
  end

  def start_year
    start_date[0..3]
  end

  def now_iso
    Time.now.utc.iso8601
  end

  # return the appropriate range.gap value for Solr based on the selected period
  GAP_FOR_SOLR = { yearly: '+1YEAR', quarterly: '+3MONTH', monthly: '+1MONTH' }.freeze
  def gap_for_solr
    GAP_FOR_SOLR[period]
  end

  # Ensure we have a valid timestamp for Solr range queries
  # @param :start - String of Time-like object
  # @return String - a date in iso8601 format
  def safe_date(start)
    Time.parse(start.to_s).utc.beginning_of_day.iso8601
  rescue ArgumentError
    safe_start_year
  end

  # provide a fallback safe starting date
  # returns January 1st, 3 Years ago in iso format
  def safe_start_year
    Time.now.years_ago(3).utc.beginning_of_year.iso8601
  end
end
