# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    title { ['Testing'] }
    factory :populated_dataset do
      title { ["The 1929 Stock Market: Irving Fisher Was Right: Additional Files"] }
      creator { ["McGrattan, Ellen R.", "Prescott, Edward C."] }
      series { ["Staff Report (Federal Reserve Bank of Minneapolis. Research Department)"] }
      resource_type { ["Dataset"] }
      visibility { "open" }
      abstract { ["This is my abstract"] }
    end
  end
end
