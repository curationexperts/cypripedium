# frozen_string_literal: true

# Note:  This is a custom migration instead of the one at
# https://github.com/samvera/hyrax/blob/v3.4.1/lib/tasks/migrate.rake#L40
# which is non-performant because
# 1) it iterates over all fedora contents instead of just work-like objects - i.e. 10x as many objects
# 2) it does it twice because it calls once for keywqords and once for license instead of handling both when a work is loaded
#
desc 'Migrate keywords and license from Hyrax 2.x to 3.x predicates'
task migrate_keywords: :environment do
  $stdout.sync = true # Flush output immediately

  start_time = Time.zone.now.localtime
  puts "Migration started at: #{start_time}"

  models_to_reindex = Hyrax.config.curation_concerns
  models_to_reindex.each do |klass|
    rows = klass.count
    puts "\nMigrating #{klass.count} #{klass} records: #{Time.zone.now.localtime}"

    id_list(klass, rows).each do |id|
      next unless ActiveFedora::Base.exists?(id)
      record = ActiveFedora::Base.find(id)
      orm = Ldp::Orm.new(record.ldp_source)
      orm.value(::RDF::Vocab::DC11.relation).each { |val| orm.graph.insert([orm.resource.subject_uri, ::RDF::Vocab::SCHEMA.keywords, val.to_s]) }
      orm.value(::RDF::Vocab::DC.rights).each { |val| orm.graph.insert([orm.resource.subject_uri, ::RDF::Vocab::DC.license, val.to_s]) }
      orm.save
      record.reload
      record.update_index
      print "."
    end
  end

  end_time = Time.zone.now.localtime
  puts "\nMigration finished at: #{end_time}"
  printf "Migration finished in: %0.1f minutes \n", time_in_minutes(start_time, end_time)
end

def solr
  Blacklight.default_index.connection
end

# Get the list of IDs from the query results:
def id_list(model, rows)
  query = { params: { q: "has_model_ssim:#{model}", fl: "id", rows: rows } }
  results = solr.select(query)
  results['response']['docs'].flat_map(&:values)
end

def time_in_minutes(start_time, end_time)
  (end_time - start_time) / 60.0
end
