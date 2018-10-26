FactoryBot.define do
  factory :file_set do
    transient do
      content { nil }
    end

    after(:create) do |file, evaluator|
      Hydra::Works::UploadFileToFileSet.call(file, evaluator.content) if evaluator.content
    end
  end
end
