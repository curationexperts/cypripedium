# frozen_string_literal: true
module Qa::Authorities
  class CorporateAuthority < Qa::Authorities::Base
    # Corresponds to endpoint authorities/search/corporate_authority?q=[q]
    # e.g. authorities/search/corporate_authority?q=Car
    def search(q)
      results = Corporate.where('lower(corporate_name) like ?', "#{q.downcase}%").limit(25)
      map_results(results)
    end

    # Corresponds to endpoint authorities/show/corporate_authority/[id]
    # e.g. authorities/show/corporate_authority/27
    def find(id)
      record = Corporate.find_by(id: id)
      return nil unless record
      {
        id: record_uri(record),
        label: record.corporate_name,
        state: record.corporate_state,
        city: record.corporate_city,
        value: record.id
      }
    end

    # Corresponds to endpoint authorities/terms/corporate_authority
    def all
      results = Corporate.all.limit(1000)
      map_results(results)
    end

    def map_results(results)
      results.map do |record|
        {
          id: record_uri(record),
          label: record.corporate_name,
          state: record.corporate_state,
          city: record.corporate_city,
          value: record.id
        }
      end
    end

    def record_uri(record)
      "#{Rails.application.config.rdf_uri}/authorities/show/corporate_authority/#{record.id}"
    end
  end
end
