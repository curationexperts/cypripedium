FactoryBot.define do
  factory :publication do
    title ['Testing']

    transient do
      file_sets []
    end

    before(:create) do |work, evaluator|
      evaluator.file_sets.each do |file_set|
        work.ordered_members << file_set
      end
    end
  end
end
