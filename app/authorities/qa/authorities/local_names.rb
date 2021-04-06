# frozen_string_literal: true
module Qa::Authorities
  class LocalNames < Qa::Authorities::Base
    # sanitize?
    def search(q)
      results = Creator.where('lower(display_name) like ?', "#{q.downcase}%").limit(25)
      results.map do |result|
        {
          id: result.id,
          label: result.display_name
        }
      end
    end

    # sanitize?
    def find(id)
      record = Creator.find_by(id: id)
      return nil unless record
      {
        id: record.id,
        label: record.display_name
      }
    end
  end
end
