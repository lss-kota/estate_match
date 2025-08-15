FactoryBot.define do
  factory :membership_plan do
    name { "MyString" }
    monthly_owner_limit { 1 }
    monthly_price { 1 }
    features { "MyText" }
    active { false }
  end
end
