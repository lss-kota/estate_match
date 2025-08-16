class Users::RegistrationsController < Devise::RegistrationsController
  private

  # 登録成功後のリダイレクト先を指定
  def after_sign_up_path_for(resource)
    if resource.agent?
      # 不動産業者の場合はウェルカムメッセージ付きでダッシュボードへ
      flash[:notice] = build_agent_welcome_message(resource)
      dashboard_path
    else
      # その他のユーザータイプは通常通り
      super
    end
  end

  # 不動産業者向けウェルカムメッセージを作成
  def build_agent_welcome_message(user)
    plan_name = user.membership_plan&.name || '未選択'
    "🎉 不動産業者として登録が完了しました！\n" \
    "会社名: #{user.company_name}\n" \
    "免許番号: #{user.license_number}\n" \
    "選択プラン: #{plan_name}\n\n" \
    "今すぐオーナーの方にメッセージを送信して、優良物件の仲介を始めましょう！"
  end
end