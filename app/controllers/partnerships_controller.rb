class PartnershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_agent_or_owner!
  before_action :set_partnership, only: [:show, :approve, :reject, :destroy]
  before_action :ensure_participant!, only: [:show, :approve, :reject, :destroy]

  # GET /partnerships
  def index
    if current_user.agent?
      @partnerships = current_user.agent_partnerships
                                 .includes(:owner)
                                 .order(created_at: :desc)
    else
      @partnerships = current_user.owner_partnerships
                                 .includes(:agent)
                                 .order(created_at: :desc)
    end
    
    @pending_requests = @partnerships.pending
    @active_partnerships = @partnerships.active
  end

  # GET /partnerships/:id
  def show
    # 詳細表示
  end

  # POST /partnerships
  def create
    @partnership = Partnership.new(partnership_params)
    
    if current_user.agent?
      @partnership.agent = current_user
    else
      @partnership.owner = current_user
    end

    if @partnership.save
      redirect_to partnerships_path, notice: 'パートナーシップリクエストを送信しました。'
    else
      redirect_back(fallback_location: properties_path, alert: @partnership.errors.full_messages.join(', '))
    end
  end

  # PATCH /partnerships/:id/approve
  def approve
    if @partnership.pending? && current_user.owner?
      @partnership.update!(status: :active, started_at: Time.current)
      redirect_to @partnership, notice: 'パートナーシップを承認しました。'
    else
      redirect_to partnerships_path, alert: '承認できません。'
    end
  end

  # PATCH /partnerships/:id/reject
  def reject
    if @partnership.pending? && current_user.owner?
      @partnership.update!(status: :terminated, ended_at: Time.current)
      redirect_to partnerships_path, notice: 'パートナーシップを拒否しました。'
    else
      redirect_to partnerships_path, alert: '拒否できません。'
    end
  end

  # DELETE /partnerships/:id
  def destroy
    @partnership.update!(status: :terminated, ended_at: Time.current)
    redirect_to partnerships_path, notice: 'パートナーシップを終了しました。'
  end

  private

  def ensure_agent_or_owner!
    unless current_user.agent? || current_user.owner?
      redirect_to root_path, alert: 'パートナーシップ機能は不動産業者とオーナーのみ利用できます。'
    end
  end

  def set_partnership
    @partnership = Partnership.find(params[:id])
  end

  def ensure_participant!
    unless @partnership.agent == current_user || @partnership.owner == current_user
      redirect_to partnerships_path, alert: 'このパートナーシップにアクセスする権限がありません。'
    end
  end

  def partnership_params
    params.require(:partnership).permit(:owner_id, :agent_id, :commission_rate, :notes)
  end
end
