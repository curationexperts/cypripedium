# frozen_string_literal: true

FactoryBot.define do
  factory :export do
    user { User.system_user }
    items { ['dummy_id'] }
    format { :bag }
  end
end
