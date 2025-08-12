FactoryBot.define do
  factory :favorite do
    association :user, factory: [:user, :buyer]
    association :property
  end
end