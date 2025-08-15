class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :destroy]
  before_action :ensure_participant!, only: [:show, :destroy]

  # GET /conversations
  # メッセージ一覧ページ
  def index
    @conversations = Conversation.for_user(current_user)
                                .includes(:property, :buyer, :owner, :agent, :inquiry, :messages)
                                .recent
                                .limit(20)
  end

  # GET /conversations/:id
  # 個別の会話ページ
  def show
    # 相手のメッセージを既読にする
    @conversation.mark_as_read_for!(current_user)
    
    # メッセージ一覧
    @messages = @conversation.messages
                           .recent
                           .includes(:sender)
                           .limit(50)
    
    # 新しいメッセージ用のオブジェクト
    @message = @conversation.messages.build
    
    # 相手ユーザー情報（複数対応）
    @other_users = @conversation.other_users(current_user)
    @other_user = @other_users.first # 後方互換性のため
    
    # 会話タイトル
    @conversation_title = @conversation.display_title(current_user)
  end

  # POST /conversations
  # 新しい会話を開始
  def create
    @property = Property.find(params[:property_id])
    
    # ユーザータイプによる処理の振り分け
    case current_user.user_type
    when 'agent'
      create_agent_conversation
    when 'buyer'
      # 購買者は直接会話できない（問い合わせのみ）
      redirect_to @property, alert: '購買者の方は「話を聞いてみる」から問い合わせを行ってください。'
    when 'owner'
      redirect_to @property, alert: 'オーナーは他のオーナーとメッセージできません。'
    else
      redirect_to @property, alert: 'メッセージ機能を利用できません。'
    end
  end

  # DELETE /conversations/:id
  # 会話を削除（参加者のみ）
  def destroy
    @conversation.destroy
    redirect_to conversations_path, notice: '会話を削除しました。'
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def ensure_participant!
    unless @conversation.participants.include?(current_user)
      redirect_to conversations_path, alert: 'この会話にアクセスする権限がありません。'
    end
  end
  
  # 不動産業者による会話作成
  def create_agent_conversation
    # 会員プランの制限チェック
    unless current_user.can_start_new_conversation?
      redirect_to @property, alert: "月間のメッセージ制限（#{current_user.membership_plan.monthly_owner_limit}件）に達しています。"
      return
    end
    
    # オーナーとの既存会話をチェック
    @conversation = Conversation.find_by(
      property: @property,
      agent: current_user,
      owner: @property.user,
      conversation_type: :agent_owner
    )
    
    # 新規作成
    if @conversation.nil?
      @conversation = Conversation.create(
        property: @property,
        agent: current_user,
        owner: @property.user,
        conversation_type: :agent_owner
      )
    end
    
    if @conversation.persisted?
      # 不動産業者のメッセージ使用数を増加
      current_user.increment_monthly_messages!
      redirect_to @conversation, notice: 'オーナーとの会話を開始しました。'
    else
      redirect_to @property, alert: "会話の作成に失敗しました: #{@conversation.errors.full_messages.join(', ')}"
    end
  end
  
  # 従来のメソッド（廃止予定）
  def find_or_create_conversation(property, buyer, owner)
    Rails.logger.warn "find_or_create_conversation is deprecated"
    
    # 既存の会話を検索（buyer_owner タイプ）
    conversation = Conversation.find_by(
      property: property,
      buyer: buyer,
      owner: owner,
      conversation_type: :buyer_owner
    )
    
    # 存在しない場合は新規作成
    conversation ||= Conversation.create(
      property: property,
      buyer: buyer,
      owner: owner,
      conversation_type: :buyer_owner
    )
    
    conversation
  end
end