# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    title { [Faker::Book.title] }
    date_uploaded { Time.zone.now }
    date_modified { Time.zone.now }

    factory :populated_publication do
      # id { Noid::Rails::Service.new.mint }
      transient do
        creators { create_list(:creator, 1) }
      end
      creator { creators.map(&:display_name) }
      creator_id { creators.map(&:id) }
      series { ["Staff Report (Federal Reserve Bank of Minneapolis. Research Department)"] }
      resource_type { ["Report"] }
      visibility { "open" }
      abstract { [Faker::Lorem.paragraph] }
      sequence(:identifier) { |n| ["https://doi.org/10.21034/sr.#{n}"] }
      description { [Faker::Lorem.paragraph] }
      date_created { [Faker::Date.between(from: 100.years.ago, to: Date.today).to_s] }
    end

    transient do
      file_sets { [] }
    end

    before(:create) do |work, evaluator|
      evaluator.file_sets.each do |file_set|
        work.ordered_members << file_set
      end
    end
  end
end
