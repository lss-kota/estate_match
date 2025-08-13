class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :destroy]
  before_action :ensure_participant!, only: [:show, :destroy]

  # GET /conversations
  # メッセージ一覧ページ
  def index
    @conversations = current_user.conversations
                                .includes(:property, :buyer, :owner, :messages)
                                .recent
                                .page(params[:page])
  end

  # GET /conversations/:id
  # 個別の会話ページ
  def show
    # 相手のメッセージを既読にする
    @conversation.mark_as_read_for!(current_user)
    
    # メッセージ一覧（ページネーション付き）
    @messages = @conversation.messages
                           .recent
                           .includes(:sender)
                           .page(params[:page])
    
    # 新しいメッセージ用のオブジェクト
    @message = @conversation.messages.build
    
    # 相手ユーザー情報
    @other_user = @conversation.other_user(current_user)
  end

  # POST /conversations
  # 新しい会話を開始（物件詳細からのお問い合わせ）
  def create
    @property = Property.find(params[:property_id])
    
    # 権限チェック
    unless current_user.can_message_about_property?(@property)
      redirect_to @property, alert: 'この物件へのお問い合わせはできません。'
      return
    end

    # 既存の会話があるかチェック
    @conversation = find_or_create_conversation(@property, current_user, @property.user)
    
    if @conversation.persisted?
      redirect_to @conversation, notice: 'メッセージを開始しました。'
    else
      redirect_to @property, alert: '会話の作成に失敗しました。'
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
    unless @conversation.buyer == current_user || @conversation.owner == current_user
      redirect_to conversations_path, alert: 'この会話にアクセスする権限がありません。'
    end
  end

  def find_or_create_conversation(property, buyer, owner)
    # 購入者とオーナーの役割を正しく設定
    actual_buyer = buyer.buyer? ? buyer : owner
    actual_owner = owner.owner? ? owner : buyer
    
    # 既存の会話を検索
    conversation = Conversation.find_by(
      property: property,
      buyer: actual_buyer,
      owner: actual_owner
    )
    
    # 存在しない場合は新規作成
    conversation ||= Conversation.create(
      property: property,
      buyer: actual_buyer,
      owner: actual_owner
    )
    
    conversation
  end
end