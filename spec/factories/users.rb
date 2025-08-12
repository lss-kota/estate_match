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
  end
end