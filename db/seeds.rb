# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 管理者ユーザーの作成
admin_user = User.find_or_initialize_by(email: 'estate.admin.2024@secure.local')

if admin_user.new_record?
  admin_user.assign_attributes(
    name: 'システム管理者',
    password: 'EstateAdmin#2024!Secure',
    password_confirmation: 'EstateAdmin#2024!Secure',
    user_type: 'admin'
  )
  
  if admin_user.save
    puts '✅ 管理者ユーザーを作成しました'
    puts "   メール: #{admin_user.email}"
    puts "   名前: #{admin_user.name}"
    puts "   ユーザータイプ: #{admin_user.user_type}"
  else
    puts '❌ 管理者ユーザーの作成に失敗しました:'
    puts "   エラー: #{admin_user.errors.full_messages.join(', ')}"
  end
else
  puts '⚠️  管理者ユーザーは既に存在します'
  puts "   メール: #{admin_user.email}"
  puts "   名前: #{admin_user.name}"
end

# 会員プランの作成
puts "\n=== 会員プラン作成 ==="

membership_plans = [
  {
    name: 'フリープラン',
    monthly_property_limit: 3,
    monthly_price: 0,
    features: ['月3物件にメッセージ可能', '基本的なプロフィール表示'],
    sort_order: 1
  },
  {
    name: 'ベーシックプラン',
    monthly_property_limit: 10,
    monthly_price: 9800,
    features: ['月10物件にメッセージ可能', '詳細プロフィール表示', 'お気に入り機能'],
    sort_order: 2
  },
  {
    name: 'プレミアムプラン',
    monthly_property_limit: 30,
    monthly_price: 19800,
    features: ['月30物件にメッセージ可能', 'プレミアムプロフィール表示', 'お気に入り機能', '優先サポート'],
    sort_order: 3
  },
  {
    name: 'エンタープライズプラン',
    monthly_property_limit: 100,
    monthly_price: 49800,
    features: ['月100物件にメッセージ可能', 'カスタムプロフィール表示', '全機能利用可能', '専任サポート', 'API利用'],
    sort_order: 4
  }
]

membership_plans.each do |plan_data|
  plan = MembershipPlan.find_or_initialize_by(name: plan_data[:name])
  
  if plan.new_record?
    plan.assign_attributes(plan_data)
    if plan.save
      puts "✅ #{plan.name}を作成しました（#{plan.formatted_price}）"
    else
      puts "❌ #{plan.name}の作成に失敗しました: #{plan.errors.full_messages.join(', ')}"
    end
  else
    puts "⚠️  #{plan.name}は既に存在します"
  end
end

# サンプル不動産業者の作成
puts "\n=== サンプル不動産業者作成 ==="

sample_agents = [
  {
    name: '田中太郎',
    email: 'tanaka@sample-estate.com',
    password: 'password123',
    company_name: '田中不動産株式会社',
    license_number: '東京都知事(1)第12345号',
    membership_plan: MembershipPlan.find_by(name: 'ベーシックプラン')
  },
  {
    name: '佐藤花子',
    email: 'sato@premium-estate.com',
    password: 'password123',
    company_name: 'プレミアム不動産',
    license_number: '東京都知事(2)第67890号',
    membership_plan: MembershipPlan.find_by(name: 'プレミアムプラン')
  }
]

sample_agents.each do |agent_data|
  agent = User.find_or_initialize_by(email: agent_data[:email])
  
  if agent.new_record?
    agent.assign_attributes(agent_data.merge(user_type: 'agent'))
    if agent.save
      puts "✅ #{agent.display_name}を作成しました"
      puts "   免許番号: #{agent.license_number}"
      puts "   プラン: #{agent.membership_plan.name}"
    else
      puts "❌ #{agent_data[:name]}の作成に失敗しました: #{agent.errors.full_messages.join(', ')}"
    end
  else
    puts "⚠️  #{agent_data[:email]}は既に存在します"
  end
end

# サンプルオーナーの作成
puts "\n=== サンプルオーナー作成 ==="

sample_owners = [
  { name: '山田一郎', email: 'yamada@example.com', password: 'password123' },
  { name: '鈴木二郎', email: 'suzuki@example.com', password: 'password123' }
]

sample_owners.each do |owner_data|
  owner = User.find_or_initialize_by(email: owner_data[:email])
  
  if owner.new_record?
    owner.assign_attributes(owner_data.merge(user_type: 'owner'))
    if owner.save
      puts "✅ #{owner.name}（オーナー）を作成しました"
    else
      puts "❌ #{owner_data[:name]}の作成に失敗しました: #{owner.errors.full_messages.join(', ')}"
    end
  else
    puts "⚠️  #{owner_data[:email]}は既に存在します"
  end
end

puts "\n=== Estate Match 初期データ読み込み完了 ==="
puts "管理者ログイン情報:"
puts "  メール: estate.admin.2024@secure.local"
puts "  パスワード: EstateAdmin#2024!Secure"
puts "  管理者パスワード: EstateSecure@Admin2024#Panel"
puts "\nサンプル不動産業者:"
puts "  田中不動産: tanaka@sample-estate.com / password123"
puts "  プレミアム不動産: sato@premium-estate.com / password123"
puts "\nサンプルオーナー:"
puts "  山田一郎: yamada@example.com / password123"
puts "  鈴木二郎: suzuki@example.com / password123"
