# frozen_string_literal: true
module Qa::Authorities
  class CreatorAuthority < Qa::Authorities::Base
    def search(q)
      results = Creator.where('lower(display_name) like ?', "#{q.downcase}%").limit(25)
      map_results(results)
    end

    def find(id)
      record = Creator.find_by(id: id)
      return nil unless record
      {
        id: record.id,
        label: record.display_name
      }
    end

    def all
      results = Creator.all.limit(1000)
      map_results(results)
    end

    def map_results(results)
      results.map do |result|
        {
          id: result.id,
          label: result.display_name
        }
      end
    end
  end
end
