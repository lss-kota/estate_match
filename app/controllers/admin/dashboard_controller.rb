class Admin::DashboardController < AdminController
  # 管理者ダッシュボード
  def index
    # 基本統計情報を計算
    @stats = {
      total_users: User.count,
      buyer_count: User.buyer.count,
      owner_count: User.owner.count,
      agent_count: User.agent.count,
      admin_count: User.admin.count,
      total_properties: Property.count,
      active_properties: Property.where(status: :active).count,
      completed_properties: Property.where(status: :completed).count,
      paused_properties: Property.where(status: :paused).count,
      total_conversations: Conversation.count,
      agent_conversations: Conversation.where(conversation_type: :agent_owner).count,
      buyer_conversations: Conversation.where(conversation_type: :buyer_owner).count,
      inquiry_conversations: Conversation.where(conversation_type: :agent_buyer_inquiry).count,
      total_messages: Message.count,
      recent_users: User.order(created_at: :desc).limit(5),
      recent_properties: Property.includes(:user).order(created_at: :desc).limit(5),
      recent_messages: Message.includes(:sender, :conversation).order(created_at: :desc).limit(10)
    }

    # 不動産業者関連統計
    @agent_stats = {
      total_agents: User.agent.count,
      active_agents: User.agent.where(id: Conversation.where.not(agent_id: nil).distinct.pluck(:agent_id)).count,
      agents_with_partnerships: User.agent.where(id: Partnership.distinct.pluck(:agent_id)).count,
      membership_plan_distribution: MembershipPlan.joins(:users).where(users: { user_type: :agent }).group('membership_plans.name').count
    }

    # パートナーシップ関連統計
    @partnership_stats = {
      total_partnerships: Partnership.count,
      active_partnerships: Partnership.active.count,
      pending_partnerships: Partnership.pending.count,
      terminated_partnerships: Partnership.terminated.count,
      partnership_success_rate: calculate_partnership_success_rate,
      avg_commission_rate: Partnership.average(:commission_rate)&.round(2) || 0
    }

    # 月別登録者数（過去6ヶ月）
    @monthly_user_registrations = (0..5).map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      {
        month: month_start.strftime('%Y年%m月'),
        total: User.where(created_at: month_start..month_end).count,
        buyers: User.buyer.where(created_at: month_start..month_end).count,
        owners: User.owner.where(created_at: month_start..month_end).count,
        agents: User.agent.where(created_at: month_start..month_end).count
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

    # 月別パートナーシップ成立数（過去6ヶ月）
    @monthly_partnerships = (0..5).map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      {
        month: month_start.strftime('%Y年%m月'),
        created: Partnership.where(created_at: month_start..month_end).count,
        activated: Partnership.active.where(started_at: month_start..month_end).count
      }
    end.reverse
  end

  private

  def calculate_partnership_success_rate
    total = Partnership.count
    return 0 if total.zero?
    
    active = Partnership.active.count
    ((active.to_f / total) * 100).round(1)
  end
end