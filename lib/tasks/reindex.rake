desc 'Re-index solr records for cypripedium works'
task reindex: :environment do
  work_classes = Hyrax.config.curation_concerns
  work_classes.each do |work_class|
    puts "Re-indexing #{work_class} records"
    work_class.all.each do |record|
      record.update_index
    end
  end
  puts "Re-index completed"
end
