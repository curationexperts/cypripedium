# frozen_string_literal: true

FactoryBot.define do
  factory :creator do
    display_name { "#{Faker::Name.last_name}, #{Faker::Name.first_name} #{Faker::Name.middle_name}" }
    repec { Faker::Alphanumeric.unique.alphanumeric(number: 10) }
    viaf { "http://viaf.org/viaf/#{Faker::Number.unique.number(digits: 14)}" }
    alternate_names { ["First Alternate", "Second Alternate"] }
  end
end
