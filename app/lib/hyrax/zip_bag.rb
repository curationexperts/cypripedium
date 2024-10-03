# frozen_string_literal: true

module Hyrax
  class ZipBag < WorkBag
    def compress
      zip_name = "#{bag_path}.zip"

      Zip::File.open(zip_name, Zip::File::CREATE) do |zip_file|
        ::Find.find(bag_path) do |file|
          relative_path = file.sub(bag_path.to_s, "#{Rails.application.config.bag_prefix}_#{time_stamp}")
          zip_file.add(relative_path, File.new(file))
        end
      end
    end
  end
end
