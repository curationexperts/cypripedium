# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    title { ["Testing"] }
    factory :populated_publication do
      title { ["The 1929 Stock Market: Irving Fisher Was Right: Additional Files"] }
      creator { ["McGrattan, Ellen R.", "Prescott, Edward C."] }
      series { ["Staff Report (Federal Reserve Bank of Minneapolis. Research Department)"] }
      resource_type { ["Dataset"] }
      visibility { "open" }
      abstract { ["This is my abstract"] }
      identifier { ["https://doi.org/10.21034/sr.600"] }
      description { ["This is my description"] }
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
