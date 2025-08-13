FactoryBot.define do
  factory :conversation do
    association :property
    association :buyer, factory: [:user, :buyer]
    association :owner, factory: [:user, :owner]
    last_message_at { Time.current }

    trait :with_messages do
      after(:create) do |conversation|
        create_list(:message, 3, conversation: conversation, sender: conversation.buyer)
        create_list(:message, 2, conversation: conversation, sender: conversation.owner)
      end
    end

    trait :recent do
      last_message_at { 1.hour.ago }
    end

    trait :old do
      last_message_at { 1.week.ago }
    end
  end
end