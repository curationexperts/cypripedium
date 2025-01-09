# frozen_string_literal: true

FactoryBot.define do
  factory :creator do
    display_name { "#{Faker::Name.last_name}, #{Faker::Name.first_name} #{Faker::Name.middle_name}" }
  end
end
