FactoryBot.define do
  factory :property do
    association :user, factory: [:user, :owner]
    title { Faker::Address.street_name + 'の物件' }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    property_type { 'house' }
    prefecture { '東京都' }
    city { '渋谷区' }
    address { Faker::Address.street_address }
    sale_price { rand(1000..10000) }
    building_area { rand(50.0..200.0).round(2) }
    land_area { rand(100.0..300.0).round(2) }
    construction_year { rand(1980..2020) }
    rooms { '3LDK' }
    parking { '有' }
    status { 'active' }

    trait :vacant_land do
      property_type { 'land' }
      building_area { nil }
      construction_year { nil }
      rooms { nil }
    end

    trait :with_rental_price do
      rental_price { rand(80000..300000) }
    end

    trait :sold do
      status { 'completed' }
    end

    trait :rented do
      status { 'completed' }
    end

    trait :draft do
      status { 'paused' }
    end
  end
end