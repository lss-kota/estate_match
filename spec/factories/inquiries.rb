FactoryBot.define do
  factory :inquiry do
    property { nil }
    buyer { nil }
    agent { nil }
    status { 1 }
    message { "MyText" }
  end
end
