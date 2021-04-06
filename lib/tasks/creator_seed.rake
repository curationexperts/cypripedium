# frozen_string_literal: true
require "csv"
namespace :vocab do
  desc "Create database-based local authorities"
  task create: :environment do
    creators_path = Rails.root.join("data", "creators.csv")
    creators = CSV.read(creators_path, headers: false)
    creators.each do |row|
      Creator.where(display_name: row.first).first_or_create do |creator|
        creator.display_name = row.first
        puts "Authority entry created #{creator.display_name}"
      end
    end

    puts Creator.count.to_s
  end
end
