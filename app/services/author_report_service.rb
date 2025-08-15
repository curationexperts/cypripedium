# frozen_string_literal: true

class AuthorReportService
  def initialize(start:)
    @start_date = start
  end

  def self.run(...)
    new(...).fetch_report
  end

  def fetch_report
    solr = Blacklight.default_index.connection
    query = {"q" => "date_created_iti:[#{@start_date} TO *]",
             "facet.field" => ["date_created_iti", "creator_sim"],
             "facet.pivot" => "creator_sim,date_created_iti",
             "rows" => "0",
             "facet" => "true",
             "wt" => "json",
             "spellcheck" => "false",
             "facet.sort" => "index",
             "facet.limit" => -1}
    response = solr.get 'select', params: query
    JSON.parse(response)
  end
end