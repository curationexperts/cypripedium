FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "person#{User.count}_#{n}@example.com"
    end
    password { 'password' }
    display_name { 'User' }
    after(:create) { |user| user.remove_role(:admin) }

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end
  end
end
