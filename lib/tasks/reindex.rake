desc 'Re-index solr records for cypripedium works & collections'
task reindex: :environment do
  $stdout.sync = true # Flush output immediately
  classes_to_reindex = [::Collection] + Hyrax.config.curation_concerns
  classes_to_reindex.each do |klass|
    puts "Re-indexing #{klass} records"
    klass.all.each do |record|
      record.update_index
    end
  end
  puts "Re-index completed"
end
