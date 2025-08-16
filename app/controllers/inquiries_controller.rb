class InquiriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inquiry, only: [:show, :start_conversation]

  # GET /inquiries
  def index
    if current_user.agent?
      @inquiries = current_user.agent_inquiries.includes(:buyer, :property).recent
    else
      redirect_to root_path, alert: '問い合わせ管理は不動産業者のみ利用できます。'
    end
  end

  # GET /inquiries/:id
  def show
    unless current_user.agent?
      redirect_to root_path, alert: '問い合わせ詳細は不動産業者のみ閲覧できます。'
    end
  end

  # POST /inquiries
  def create
    @inquiry = Inquiry.new(inquiry_params)
    @inquiry.buyer = current_user

    if @inquiry.save
      redirect_to @inquiry.property, notice: '問い合わせを送信しました。不動産業者からの連絡をお待ちください。'
    else
      redirect_back(fallback_location: root_path, alert: @inquiry.errors.full_messages.join(', '))
    end
  end

  # PATCH /inquiries/:id/start_conversation
  def start_conversation
    if @inquiry.agent != current_user
      redirect_to inquiries_path, alert: 'この問い合わせに対する権限がありません。'
      return
    end

    begin
      conversation = @inquiry.create_conversation!
      redirect_to conversation, notice: '顧客との会話を開始しました。'
    rescue => e
      redirect_to @inquiry, alert: "会話の開始に失敗しました: #{e.message}"
    end
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(:property_id, :agent_id, :message)
  end
end
