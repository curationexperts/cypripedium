module Qa::Authorities
  class LocalNames < Qa::Authorities::Base
    attr_reader :subauthority
    # sanitize?
    def search(_q)
      Creator.where('lower(display_name) like ?', "#{_q.downcase}%").limit(25)
    end
    # sanitize?
    def find(id)
      record = Creator.find_by(id: id)
      return nil unless record
      record
    end
  end
end
