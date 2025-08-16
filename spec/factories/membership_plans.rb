FactoryBot.define do
  factory :membership_plan do
    name { 'ベーシックプラン' }
    monthly_property_limit { 10 }
    monthly_price { 9800 }
    features { ['月10物件にメッセージ可能', '詳細プロフィール表示'] }
    active { true }
    sort_order { 1 }
  end
end
