FactoryBot.define do
  factory :membership_plan do
    name { 'ベーシックプラン' }
    monthly_owner_limit { 10 }
    monthly_price { 9800 }
    features { ['月10人のオーナーにメッセージ可能', '詳細プロフィール表示'] }
    active { true }
    sort_order { 1 }
  end
end
