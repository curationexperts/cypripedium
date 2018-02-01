module Hyrax
  module HasZip
    extend ActiveSupport::Concern

    def work_zip
      WorkZip.latest(id).first || WorkZip.new(work_id: id)
    end
  end
end
