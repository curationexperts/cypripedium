namespace :import do
  desc "Import data from ContentDM export"
  task contentdm: :environment do
    import_data
    exit 0 # Make sure extra args aren't misinterpreted as rake task args
  end

  # helpers
  #
  def import_data
    options = options(ARGV)
    puts "Importing records using options: #{options}"
    Contentdm::Importer.import(options[:input_file])
    puts "Import complete"
  end

  # Read the options that the user supplied on the command line
  def options(args)
    require 'optparse'
    user_inputs = {}
    opts = OptionParser.new
    opts.on('-i INPUT FILE', '--input_file', 'The XML file containing the ContentDM records you want to import (required)') do |input_file|
      user_inputs[:input_file] = input_file
    end
    opts.on('-h', '--help', 'Print this help message') do
      puts opts
      exit 0
    end
    args = opts.order!(ARGV) {}
    opts.parse!(args)
    user_inputs
  end
end
