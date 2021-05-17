# frozen_string_literal: true
module Qa::Authorities
  class CreatorAuthority < Qa::Authorities::Base
    # Corresponds to endpoint authorities/search/creator_authority?q=[q]
    # e.g. authorities/search/creator_authority?q=Car
    def search(q)
      results = Creator.where('active_creator AND lower(display_name) like ?', "#{q.downcase}%").limit(25)
      map_results(results)
    end

    # Corresponds to endpoint authorities/show/creator_authority/[id]
    # e.g. authorities/show/creator_authority/27
    def find(id)
      record = Creator.find_by(id: id)
      return nil unless record
      {
        id: record_uri(record),
        label: record.display_name,
        active: record.active_creator
      }
    end

    # Corresponds to endpoint authorities/terms/creator_authority
    def all
      results = Creator.all.limit(1000)
      map_results(results)
    end

    def map_results(results)
      results.map do |record|
        {
          id: record_uri(record),
          label: record.display_name,
          active: record.active_creator,
          value: record.id
        }
      end
    end

    def record_uri(record)
      "#{Rails.application.config.rdf_uri}/authorities/show/creator_authority/#{record.id}"
    end
  end
end
