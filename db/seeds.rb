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

puts "\n=== Estate Match 初期データ読み込み完了 ==="
puts "管理者ログイン情報:"
puts "  メール: estate.admin.2024@secure.local"
puts "  パスワード: EstateAdmin#2024!Secure"
puts "  管理者パスワード: EstateSecure@Admin2024#Panel"
