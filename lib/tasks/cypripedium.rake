# frozen_string_literal: true
namespace :cypripedium do
  desc "Setup standard admin login account"
  task standard_users_setup: :environment do
    if ENV["RAILS_ENV"] != "production"
      create_first_admin_user
    else
      puts "Rails running in production mode, not creating first user or first admin"
    end
  end

  def create_first_admin_user
    u = User.find_or_create_by(email: "admin@testdomain.com")
    u.display_name = "Test Admin"
    u.password = "password"
    u.password_confirmation = "password"
    u.save!
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << u
    admin_role.save!
  end

  desc "Normalize date_modified field"
  task normalize_date_modified: :environment do
    current_offset = 0
    documents = [{ 'id' => 'dummy' }] # dummy value to trigger first loop iteration
    ids = []
    puts "===================================================="
    while documents.present?
      print "\rFetching documents from Solr (offset: #{current_offset})"
      $stdout.flush
      response = Hyrax::SolrService.get('date_modified_ssi:*', rows: 100, start: current_offset)
      documents = response.dig('response', 'docs') || []
      ids += documents.map { |doc| doc['id'] }
      current_offset += 100
    end

    puts "\n"
    total = ids.length
    ids.each.with_index do |id, index|
      af_object = ActiveFedora::Base.find(id)
      af_object.date_modified = af_object.date_modified.in_time_zone
      af_object.save!

      print "\rProcessing #{index} of #{total}"
      $stdout.flush
    end

    puts "\n"
  end

  desc "Update JEL subject codes"
  task update_jels: :environment do
    JELS = %w[E12 E62 G10 G12 G51 J14 P16 P20 P24 P27 P29 Q18 R14].freeze

    puts "===================================================="
    JELS.each do |jel|
      label = Qa::Authorities::Local.subauthority_for('jels').search(jel)&.first&.dig('label')
      puts label || "No label found for #{jel}"
      response = Hyrax::SolrService.get("subject_tesim:#{jel}", rows: 100)
      documents = response.dig('response', 'docs') || []
      ids = documents.map { |doc| doc['id'] }
      ids = [] unless label
      total = ids.length
      ids.each.with_index do |id, index|
        work = ActiveFedora::Base.find(id)
        subjects = work.subject.to_a
        idx = subjects.index { |subject| subject.start_with?(jel) }
        subjects[idx] = label
        work.subject = subjects
        # work.save!

        print "\rProcessing #{index} of #{total}"
        $stdout.flush
      end
      puts "\n\n"
    end
  end
end
