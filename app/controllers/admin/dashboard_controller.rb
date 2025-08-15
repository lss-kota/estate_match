class Admin::DashboardController < AdminController
  # 管理者ダッシュボード
  def index
    # 統計情報を計算
    @stats = {
      total_users: User.count,
      buyer_count: User.buyer.count,
      owner_count: User.owner.count,
      admin_count: User.admin.count,
      total_properties: Property.count,
      active_properties: Property.where(status: :active).count,
      completed_properties: Property.where(status: :completed).count,
      paused_properties: Property.where(status: :paused).count,
      total_conversations: Conversation.count,
      total_messages: Message.count,
      recent_users: User.order(created_at: :desc).limit(5),
      recent_properties: Property.includes(:user).order(created_at: :desc).limit(5),
      recent_messages: Message.includes(:sender, :conversation).order(created_at: :desc).limit(10)
    }

    # 月別登録者数（過去6ヶ月）
    @monthly_user_registrations = (0..5).map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      {
        month: month_start.strftime('%Y年%m月'),
        count: User.where(created_at: month_start..month_end).count
      }
    end.reverse

    # 月別物件投稿数（過去6ヶ月）
    @monthly_property_posts = (0..5).map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      {
        month: month_start.strftime('%Y年%m月'),
        count: Property.where(created_at: month_start..month_end).count
      }
    end.reverse
  end
end