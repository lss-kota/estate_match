FactoryBot.define do
  factory :message do
    association :conversation
    association :sender, factory: :user
    content { Faker::Lorem.sentence(word_count: 10) }

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :unread do
      read_at { nil }
    end

    trait :recent do
      created_at { 1.hour.ago }
    end

    trait :old do
      created_at { 1.week.ago }
    end

    trait :long_content do
      content { Faker::Lorem.paragraph(sentence_count: 5) }
    end

    trait :short_content do
      content { "Hi!" }
    end
  end
end