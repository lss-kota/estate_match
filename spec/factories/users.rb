FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { Faker::Name.name }
    user_type { 'buyer' }

    trait :owner do
      user_type { 'owner' }
    end

    trait :buyer do
      user_type { 'buyer' }
    end
    
    trait :agent do
      user_type { 'agent' }
      company_name { Faker::Company.name }
      license_number { "東京都知事(1)第#{rand(10000..99999)}号" }
      association :membership_plan
    end
    
    trait :admin do
      user_type { 'admin' }
    end
  end
end