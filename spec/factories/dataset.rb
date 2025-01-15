# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    title { ['Testing'] }

    factory :dataset_without_description do
      transient do
        creators { create_list(:creator, 2) }
      end
      title { ["The 1929 Stock Market: Irving Fisher Was Right: Additional Files"] }
      creator { creators.map(&:display_name) }
      creator_id { creators.map(&:id) }
      series { ["Staff Report (Federal Reserve Bank of Minneapolis. Research Department)"] }
      resource_type { ["Dataset"] }
      visibility { "open" }
      abstract { ["This is my abstract"] }
      identifier { ["https://doi.org/10.21034/sr.600"] }
      related_url { ["Data supports Staff Report 315, \"Does Neoclassical Theory Account for the Effects of Big Fiscal Shocks? Evidence From World War II.\" https://doi.org/10.21034/sr.315"] }

      factory :populated_dataset do
        description { ["This is my description"] }
        license { ["https://creativecommons.org/licenses/by-nc/4.0/"] }
      end
    end
  end
end
