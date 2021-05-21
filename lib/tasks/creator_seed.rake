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
        creator.display_name = row["display_name"]
        puts "Authority entry created #{creator.display_name}"
      end
    end

    puts Creator.count.to_s
  end

  desc "Go through all Fedora records and add creator_ids associated with creators"
  task migrate: :environment do
    creators_array = Creator.pluck(:id, :display_name).map { |id, name| { id: id, name: name } }

    models_to_reindex = Hyrax.config.curation_concerns
    models_to_reindex.each do |klass|
      rows = klass.count
      puts "Re-indexing #{klass.count} #{klass} records: #{Time.zone.now.localtime}"

      id_list(klass, rows).each do |id|
        next unless ActiveFedora::Base.exists?(id)
        record = ActiveFedora::Base.find(id)
        next if record.creator.empty?
        puts "Record id: #{id}"
        record.creator.each do |creator|
          puts "Creator name: #{creator}"
          creator_identifier = creators_array.find { |ca| ca[:name] == creator }[:id]
          record.creator_id = record.creator_id + [creator_identifier.to_s]
        end
        record.save
      end

      end_time = Time.zone.now.localtime
      puts "Re-index finished at: #{end_time}"
      printf "Re-index finished in: %0.1f minutes \n", time_in_minutes(start_time, end_time)
    end
  end
end
