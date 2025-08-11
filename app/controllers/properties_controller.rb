class PropertiesController < ApplicationController
  # 物件一覧・詳細は未ログインユーザーでも閲覧可能
  skip_before_action :authenticate_user!, only: [:index, :show]
  
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner!, only: [:new, :create, :edit, :update, :destroy]
  before_action :ensure_owner_of_property!, only: [:edit, :update, :destroy]

  # GET /properties
  def index
    @properties = Property.includes(:user, :tags, images_attachments: :blob)
                         .where(status: :active)
                         .order(created_at: :desc)
                         .page(params[:page])
  end

  # GET /properties/:id
  def show
    @property = Property.includes(:user, :tags, images_attachments: :blob)
                       .find(params[:id])
  end

  # GET /properties/new (従来のフォーム - 必要に応じて残す)
  def new
    @property = current_user.properties.build
    @tags = Tag.all.group_by(&:category)
  end

  # === 簡単STEP形式投稿（5ステップ） ===
  
  # STEP 1: 取引種別選択
  def new_step1
    session[:property_data] = {} if session[:property_data].nil?
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step1", locals: { step_data: session[:property_data] })
  end

  def save_step1
    session[:property_data] ||= {}
    session[:property_data].merge!(step1_params)
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step2", locals: { step_data: session[:property_data] })
  end

  # STEP 2: 基本情報
  def new_step2
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step2", locals: { step_data: session[:property_data] })
  end

  def save_step2
    session[:property_data].merge!(step2_params)
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step3", locals: { step_data: session[:property_data] })
  end

  # STEP 3: 所在地情報
  def new_step3
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step3", locals: { step_data: session[:property_data] })
  end

  def save_step3
    session[:property_data].merge!(step3_params)
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step4", locals: { step_data: session[:property_data] })
  end

  # STEP 4: 価格設定
  def new_step4
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step4", locals: { step_data: session[:property_data] })
  end

  def save_step4
    session[:property_data].merge!(step4_params)
    render turbo_stream: turbo_stream.replace("property_modal_content", 
      partial: "properties/steps/step5", locals: { step_data: session[:property_data] })
  end

  # STEP 5: 確認・投稿
  def new_step5
    @property = build_property_from_session
    render layout: false
  end

  def create_from_steps
    # セッションから物件データを取得して正しいパラメータでbuild
    property_params = session[:property_data].slice(
      'title', 'description', 'property_type', 'prefecture', 'city', 'address'
    )
    
    # 価格データの変換（文字列から数値へ）
    if session[:property_data]['sale_price'].present?
      property_params['sale_price'] = session[:property_data]['sale_price'].to_i
    end
    
    if session[:property_data]['rental_price'].present?
      property_params['rental_price'] = session[:property_data]['rental_price'].to_i
    end

    @property = current_user.properties.build(property_params)
    @property.status = :active  # デフォルトで募集中にする

    if @property.save
      session.delete(:property_data)
      
      # Ajax request handling
      if request.xhr?
        render json: { status: 'success', message: '🎉 物件を投稿しました！' }
      else
        redirect_to dashboard_path, notice: '🎉 物件を投稿しました！'
      end
    else
      if request.xhr?
        render json: { status: 'error', errors: @property.errors.full_messages }
      else
        render turbo_stream: turbo_stream.replace("property_modal_content", 
          partial: "properties/steps/step5", locals: { 
            step_data: session[:property_data], 
            property: @property,
            errors: @property.errors 
          })
      end
    end
  end

  def clear_session
    session.delete(:property_data)
    head :no_content
  end

  # POST /properties
  def create
    @property = current_user.properties.build(property_params)
    
    if @property.save
      redirect_to @property, notice: '物件を投稿しました！'
    else
      @tags = Tag.all.group_by(&:category)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /properties/:id/edit
  def edit
    @tags = Tag.all.group_by(&:category)
  end

  # PATCH/PUT /properties/:id
  def update
    if @property.update(property_params)
      redirect_to @property, notice: '物件情報を更新しました！'
    else
      @tags = Tag.all.group_by(&:category)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:id
  def destroy
    @property.destroy
    redirect_to my_properties_path, notice: '物件を削除しました。'
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def ensure_owner!
    unless current_user.owner?
      redirect_to properties_path, alert: 'オーナーのみ利用可能な機能です。'
    end
  end

  def ensure_owner_of_property!
    unless @property.user == current_user
      redirect_to properties_path, alert: '他のユーザーの物件は編集できません。'
    end
  end

  def property_params
    params.require(:property).permit(
      :title, :description, :sale_price, :rental_price, :deposit, :key_money, :management_fee,
      :prefecture, :city, :address, :nearest_station, :station_distance,
      :property_type, :building_area, :land_area, :rooms, :construction_year, :parking,
      :status, images: [], floor_plan: nil, tag_ids: []
    )
  end

  # === 簡単STEP別パラメータ ===
  def step1_params
    params.permit(:transaction_type)
  end

  def step2_params
    params.permit(:title, :description, :property_type)
  end

  def step3_params
    params.permit(:prefecture, :city, :address)
  end

  def step4_params
    # STEP1の選択に応じて価格パラメータを処理
    case session[:property_data]['transaction_type']
    when 'sale_only'
      params.permit(:sale_price)
    when 'rent_only'
      params.permit(:rental_price)
    when 'both'
      params.permit(:sale_price, :rental_price)
    else
      params.permit(:sale_price, :rental_price)
    end
  end

  def build_property_from_session
    return nil unless session[:property_data]
    current_user.properties.build(session[:property_data])
  end
end
