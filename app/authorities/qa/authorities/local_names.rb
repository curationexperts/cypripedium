module Qa::Authorities
  class LocalNames < Qa::Authorities::Base
    attr_reader :subauthority
    # sanitize?
    def search(_q)
      Creator.where('lower(display_name) like ?', "#{_q.downcase}%").limit(25)
    end
    # sanitize?
    def find(id)
      begin
        Creator.find(id)
      rescue ActiveRecord::RecordNotFound
        {"add a json response here saying the record can't be found"}
      end
    end
  end
end
