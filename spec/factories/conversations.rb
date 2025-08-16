FactoryBot.define do
  factory :conversation do
    association :property
    association :buyer, factory: [:user, :buyer]
    association :owner, factory: [:user, :owner]
    last_message_at { Time.current }
    conversation_type { :buyer_owner }
    
    # 従来の買い手-オーナー間会話（廃止予定だが既存テスト対応）
    factory :buyer_owner_conversation do
      association :buyer, factory: [:user, :buyer]
      conversation_type { :buyer_owner }
    end
    
    # 不動産業者-オーナー間会話
    factory :agent_owner_conversation do
      association :agent, factory: [:user, :agent]
      conversation_type { :agent_owner }
    end
    
    # 3者間会話（問い合わせ由来）
    factory :inquiry_conversation do
      association :buyer, factory: [:user, :buyer]
      association :agent, factory: [:user, :agent]
      association :inquiry
      conversation_type { :agent_buyer_inquiry }
    end

    trait :with_messages do
      after(:create) do |conversation|
        case conversation.conversation_type
        when 'buyer_owner'
          create_list(:message, 3, conversation: conversation, sender: conversation.buyer)
          create_list(:message, 2, conversation: conversation, sender: conversation.owner)
        when 'agent_owner'
          create_list(:message, 3, conversation: conversation, sender: conversation.agent)
          create_list(:message, 2, conversation: conversation, sender: conversation.owner)
        when 'agent_buyer_inquiry'
          create_list(:message, 2, conversation: conversation, sender: conversation.buyer)
          create_list(:message, 2, conversation: conversation, sender: conversation.agent)
          create_list(:message, 1, conversation: conversation, sender: conversation.owner)
        end
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