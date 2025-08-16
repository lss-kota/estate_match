class PartnershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_agent_or_owner!
  before_action :set_partnership, only: [:show, :approve, :reject, :destroy, :handle_request]
  before_action :ensure_participant!, only: [:show, :approve, :reject, :destroy, :handle_request]

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
      # action_typeパラメータがあればそれに従って処理
      if params[:action_type].present?
        action_type = params[:action_type]
        conversation = find_conversation_for_partnership(@partnership)
        
        case action_type
        when 'request'
          if current_user.agent?
            @partnership.agent_request!
            message = 'パートナーシップを申請しました。'
          elsif current_user.owner?
            @partnership.owner_request!
            message = 'パートナーシップを申請しました。'
          end
        when 'approve'
          if current_user.agent? && @partnership.owner_requested?
            @partnership.agent_request!
            message = 'パートナーシップが成立しました！'
          elsif current_user.owner? && @partnership.agent_requested?
            @partnership.owner_request!
            message = 'パートナーシップが成立しました！'
          else
            message = '承認できません。'
          end
        else
          message = '不正な操作です。'
        end
        
        if conversation
          redirect_to conversation, notice: message
        else
          redirect_to partnerships_path, notice: message
        end
      else
        redirect_to partnerships_path, notice: 'パートナーシップリクエストを送信しました。'
      end
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

  # POST /partnerships/:id/request
  def handle_request
    handle_request_internal(params[:action_type])
  end

  private

  def handle_request_internal(action_type)
    conversation = Conversation.joins(:property)
                              .where(property: { user: [@partnership.agent, @partnership.owner] })
                              .where(agent: @partnership.agent, owner: @partnership.owner)
                              .first

    case action_type
    when 'request'
      if current_user.agent?
        @partnership.agent_request!
        message = 'パートナーシップを申請しました。'
      elsif current_user.owner?
        @partnership.owner_request!
        message = 'パートナーシップを申請しました。'
      end
    when 'approve'
      if current_user.agent? && @partnership.owner_requested?
        @partnership.agent_request!
        message = 'パートナーシップが成立しました！'
      elsif current_user.owner? && @partnership.agent_requested?
        @partnership.owner_request!
        message = 'パートナーシップが成立しました！'
      else
        message = '承認できません。'
      end
    when 'cancel'
      @partnership.cancel_request!(current_user)
      message = '申請を取り消しました。'
    when 'decline'
      @partnership.cancel_request!(current_user)
      message = '申請を辞退しました。'
    when 'terminate'
      @partnership.destroy!
      message = 'パートナーシップを解除しました。'
    else
      message = '不正な操作です。'
    end

    if conversation
      redirect_to conversation, notice: message
    else
      redirect_to partnerships_path, notice: message
    end
  end

  def ensure_agent_or_owner!
    unless current_user.agent? || current_user.owner?
      redirect_to root_path, alert: 'パートナーシップ機能は不動産業者とオーナーのみ利用できます。'
    end
  end

  def set_partnership
    if params[:id].present?
      @partnership = Partnership.find(params[:id])
    else
      # 新規作成の場合は、パートナーシップを初期化
      @partnership = Partnership.new
    end
  end

  def ensure_participant!
    unless @partnership.agent == current_user || @partnership.owner == current_user
      redirect_to partnerships_path, alert: 'このパートナーシップにアクセスする権限がありません。'
    end
  end

  def partnership_params
    params.require(:partnership).permit(:owner_id, :agent_id, :commission_rate, :notes)
  end

  def find_conversation_for_partnership(partnership)
    Conversation.joins(:property)
               .where(property: { user: [partnership.agent, partnership.owner] })
               .where(agent: partnership.agent, owner: partnership.owner)
               .first
  end
end
