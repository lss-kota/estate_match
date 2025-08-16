FactoryBot.define do
  factory :inquiry do
    association :property
    association :buyer, factory: [:user, :buyer]
    association :agent, factory: [:user, :agent]
    status { :pending }
    message { "この物件について詳しく話を聞きたいです。" }
  end
end
