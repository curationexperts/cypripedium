# frozen_string_literal: true
require "csv"
namespace :creators do
  desc "Collects creator names and saves them to csv"
  task collect: :environment do
    creators_path = Rails.root.join("data", "creators.csv")

    solr = Blacklight.default_index.connection

    response = solr.get 'select', params: { "facet.field": ["creator_sim"], "facet.limit":-1 }
    creators_array = response["facet_counts"]["facet_fields"]["creator_sim"]

    CSV.open(creators_path, 'w', write_headers: true, headers: ["display_name", "result_count"]) do |row|
      creators_array.each_slice(2) do |pair|
        row << pair
      end
    end
    # Same as above, one-line syntax
    # CSV.open(creators_path,'w', :write_headers=> true, :headers => ["display_name", "result_count"]) { |row| creators_array.each_slice(2) { |pair| row << pair } }
  end

  desc "Create database-based local authorities"
  task create: :environment do
    creators_path = Rails.root.join("data", "creators.csv")
    creators = CSV.read(creators_path, headers: true)
    creators.each do |row|
      Creator.where(display_name: row["display_name"]).first_or_create do |creator|
        creator.display_name = row["display_name"].strip
        puts "Authority entry created #{creator.display_name}"
      end
    end

    puts Creator.count.to_s
  end

  desc "Go through all Fedora records and add creator_ids associated with creators"
  task migrate: :environment do
    $stdout.sync = true # Flush output immediately

    start_time = Time.zone.now.localtime
    creators_array = Creator.pluck(:id, :display_name).map { |id, name| { id: id, name: name } }

    models_to_reindex = Hyrax.config.curation_concerns
    models_to_reindex.each do |klass|
      rows = klass.count


      records = ids_list(klass, rows).map { |id| ActiveFedora::Base.find(id) }
      puts "Migrating creators for #{records.count} out of #{klass.count} #{klass} records: #{Time.zone.now.localtime}"
      records.map do |record|
        record.creator.map do |creator|
          creator_identifier = creators_array.find { |ca| ca[:name] == creator.strip }[:id]
          record.creator_id = record.creator_id + [creator_identifier.to_s]
        end
        record.save
      end
    end
    end_time = Time.zone.now.localtime
    puts "Creator migration finished at: #{end_time}"
    printf "Creator migration finished in: %0.1f minutes \n", time_in_minutes(start_time, end_time)
  end
end

# Have to override reindex id_list method to filter out Private works, which are creating errors
# Search for works that are open visibility, do have a creator, and do not already have a creator_id
def ids_list(model, rows)
  query = { params: { q: "has_model_ssim:#{model}", fq: ["visibility_ssi:open", "creator_sim:*", "-creator_id_ssim:*"], fl: "id", rows: rows } }
  results = solr.select(query)
  results['response']['docs'].flat_map(&:values)
end
