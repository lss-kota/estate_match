FactoryBot.define do
  factory :partnership do
    association :agent, factory: [:user, :agent]
    association :owner, factory: [:user, :owner]
    status { :active }
    started_at { Time.current }
    ended_at { nil }
    commission_rate { 5.0 }
    agent_requested_at { Time.current }
    owner_requested_at { Time.current }
  end
end
