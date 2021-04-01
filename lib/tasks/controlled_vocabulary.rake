# frozen_string_literal: true
require "csv"
namespace :vocab do
  desc "Create database-based local authorities"
  task create: :environment do
    creators_auth = Qa::LocalAuthority.find_or_create_by(name: 'creators')
    creators_path = Rails.root.join("spec", "fixtures", "creators", "list_creators.csv")
    creators = CSV.read(creators_path, headers: false)

    creators.each do |creator|
      Qa::LocalAuthorityEntry.where(local_authority: creators_auth, label: creator.first).first_or_create do |auth_entry|
        auth_entry.local_authority = creators_auth
        auth_entry.label = creator.first
        puts "Authority entry created #{auth_entry.label}"
      end
    end

    puts "#{Qa::LocalAuthorityEntry.count}"
  end
end
