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
    Contentdm::Importer.import(options[:input_file], options[:data_path], options[:work_type])
    puts "Import complete"
  end

  # Read the options that the user supplied on the command line.
  # This uses the OptionParser from ruby's "standard library":
  # https://ruby-doc.org/stdlib-2.4.2/libdoc/optparse/rdoc/OptionParser.html
  def options(args)
    require 'optparse'
    user_inputs = {}
    opts = OptionParser.new

    opts.on('-i INPUT FILE', '--input_file', '(required) The XML file containing the ContentDM records you want to import') do |input_file|
      user_inputs[:input_file] = input_file
    end

    opts.on('-d DATA PATH', '--data_path', '(required) The path to the directory where the collection folders are stored') do |data_path|
      user_inputs[:data_path] = data_path
    end

    opts.on('-w WORK TYPE', '--work_type', '(required) The type of work records to create by default.  Valid choices are: ConferenceProceeding, DataSet, Publication') do |work_type|
      user_inputs[:work_type] = work_type
    end

    opts.on('-h', '--help', 'Print this help message') do
      puts opts
      exit 0
    end

    args = opts.order!(ARGV) {}
    opts.parse!(args)

    required_options = [:input_file, :data_path, :work_type]
    missing_options = required_options - user_inputs.keys
    missing_options.each { |o| puts "Error: Missing required option: --#{o}" }

    # If any required options are missing, print the usage message and abort.
    unless missing_options.blank?
      puts ""
      puts opts
      exit 1
    end

    user_inputs
  end
end
