# frozen_string_literal: true

namespace :cleanup do
  desc 'Clean up old zip files for bulk downloads'
  task zips: :environment do
    dir = WorkZip.new.path_root
    zip_files = File.join(dir, '*.zip')
    age = 7.days.ago

    Dir.glob(zip_files) do |file|
      next if File.mtime(file) > age
      # puts "deleting: #{file}"
      File.delete(file)
    end
  end
end
