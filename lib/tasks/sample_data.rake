# frozen_string_literal: true

desc 'Create some fake sample data in your dev environment'
task sample_data: :environment do
  $stdout.sync = true # Flush output immediately

  puts "Creating some fake sample data"

  puts "Make sure the default AdminSet exists"
  AdminSet.find_or_create_default_admin_set_id

  ['Collection One 111', 'Collection Two 222'].each do |title|
    puts "Create a Collection: #{title}"
    ::Collection.create!(title: [title], visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, collection_type: Hyrax::CollectionType.find_or_create_default_collection_type)
  end

  data_path = Rails.root.join('spec', 'fixtures', 'files')

  puts 'Import some works for "Sargent and Sims" collection'
  sargent_file = Rails.root.join('lib', 'tasks', 'sample_data', 'sargent_sample.xml')
  Contentdm::Importer.import(sargent_file, data_path, 'Publication')

  puts 'Import some works for "Conference Proceedings" collection'
  conference_file = Rails.root.join('lib', 'tasks', 'sample_data', 'conference_proceedings_sample.xml')
  Contentdm::Importer.import(conference_file, data_path, 'Publication')

  puts "Done."
end
