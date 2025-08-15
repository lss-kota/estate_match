FactoryBot.define do
  factory :partnership do
    association :agent, factory: :user, user_type: :agent
    association :owner, factory: :user, user_type: :owner
    status { :active }
    started_at { Time.current }
    ended_at { nil }
    commission_rate { 5.0 }
  end
end
