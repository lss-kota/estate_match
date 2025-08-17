class Admin::PartnershipsController < AdminController
  before_action :set_partnership, only: [:show, :destroy, :toggle_status]

  def index
    @partnerships = Partnership.includes(:agent, :owner).order(created_at: :desc)
    
    # フィルタリング
    if params[:status].present? && params[:status] != 'all'
      @partnerships = @partnerships.where(status: params[:status])
    end
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @partnerships = @partnerships.joins(:agent, :owner)
                                 .where("users.name LIKE ? OR owners_partnerships.name LIKE ?", 
                                       search_term, search_term)
    end
    
    @partnerships = @partnerships.page(params[:page]).per(20) if defined?(Kaminari)
    
    # 統計情報
    @stats = {
      total_partnerships: Partnership.count,
      active_partnerships: Partnership.active.count,
      pending_partnerships: Partnership.pending.count,
      terminated_partnerships: Partnership.terminated.count,
      today_partnerships: Partnership.where('created_at >= ?', Date.current.beginning_of_day).count,
      avg_commission_rate: Partnership.average(:commission_rate)&.round(2) || 0
    }
  end

  def show
    @conversations = Conversation.where(agent: @partnership.agent, owner: @partnership.owner)
                                .includes(:property, :messages)
                                .order(created_at: :desc)
  end

  def destroy
    @partnership.destroy
    redirect_to admin_partnerships_path, notice: 'パートナーシップを削除しました。'
  end

  def toggle_status
    case @partnership.status
    when 'pending'
      @partnership.update(status: :active, started_at: Time.current)
      notice = 'パートナーシップを承認しました。'
    when 'active'
      @partnership.update(status: :terminated, ended_at: Time.current)
      notice = 'パートナーシップを終了しました。'
    when 'terminated'
      @partnership.update(status: :active, started_at: Time.current, ended_at: nil)
      notice = 'パートナーシップを再開しました。'
    end
    
    redirect_to admin_partnership_path(@partnership), notice: notice
  end

  private

  def set_partnership
    @partnership = Partnership.find(params[:id])
  end
end
