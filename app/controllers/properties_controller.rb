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
    
    # 検索条件を適用
    @properties = apply_search_filters(@properties)
    
    # ソート条件を適用
    @properties = apply_sort_order(@properties)
    
    # ページネーション（一時的にlimit使用、後でKaminari追加）
    @properties = @properties.limit(12)
  end

  # GET /properties/:id
  def show
    @property = Property.includes(:user, :tags, images_attachments: :blob)
                       .find(params[:id])
    # 編集画面からの遷移かどうかをチェック
    @came_from_edit = session.delete(:came_from_edit)
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
    # 画像削除処理
    handle_image_deletions if params[:property][:delete_image_ids].present?
    handle_floor_plan_deletion if params[:property][:delete_floor_plan] == '1'

    # 画像の処理
    property_attrs = property_params
    handle_image_attachments(property_attrs)

    if @property.update(property_attrs)
      # 編集画面からの更新であることをセッションに保存
      session[:came_from_edit] = true
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
      :status, :transaction_type, :delete_floor_plan, :floor_plan, images: [], tag_ids: [], delete_image_ids: []
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

  # 指定された画像を削除する
  def handle_image_deletions
    delete_ids = params[:property][:delete_image_ids]
    delete_ids = [delete_ids] unless delete_ids.is_a?(Array)
    
    delete_ids.each do |signed_id|
      next if signed_id.blank?
      
      begin
        # signed_idからBlobを取得して、該当するAttachmentを削除
        blob = ActiveStorage::Blob.find_signed(signed_id)
        if blob
          @property.images.attachments.where(blob_id: blob.id).each(&:purge)
        end
      rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound => e
        # 無効なsigned_idまたは画像が見つからない場合はスキップ
        Rails.logger.warn("Image with signed_id #{signed_id} not found: #{e.message}")
      end
    end
  end

  # 間取り図を削除する
  def handle_floor_plan_deletion
    @property.floor_plan.purge if @property.floor_plan.attached?
  end

  # 画像の添付処理
  def handle_image_attachments(property_attrs)
    # 削除用パラメータを除去（これらはモデルの属性ではない）
    property_attrs.delete(:delete_image_ids)
    property_attrs.delete(:delete_floor_plan)
    
    # 新しい画像が送信された場合のみ、既存の画像に追加
    if property_attrs[:images].present? && property_attrs[:images].any?(&:present?)
      new_images = property_attrs[:images].select(&:present?)
      @property.images.attach(new_images)
      # パラメータから削除して重複添付を防ぐ
      property_attrs.delete(:images)
    else
      # 新しい画像がない場合はimagesパラメータを削除
      property_attrs.delete(:images)
    end

    # 間取り図の処理 - 新しいファイルがある場合のみ置き換え
    if property_attrs[:floor_plan].present?
      # 新しい間取り図がある場合は既存を置き換え
    else
      # 新しい間取り図がない場合はfloor_planパラメータを削除
      property_attrs.delete(:floor_plan)
    end
  end

  # 検索・フィルタ条件を適用
  def apply_search_filters(properties)
    # キーワード検索（タイトル・説明・住所）
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      properties = properties.where(
        "title LIKE ? OR description LIKE ? OR prefecture LIKE ? OR city LIKE ? OR address LIKE ?",
        search_term, search_term, search_term, search_term, search_term
      )
    end

    # 取引種別フィルタ
    if params[:transaction_type].present?
      case params[:transaction_type]
      when 'sale'
        properties = properties.where.not(sale_price: nil)
      when 'rent'
        properties = properties.where.not(rental_price: nil)
      when 'both'
        properties = properties.where.not(sale_price: nil).where.not(rental_price: nil)
      end
    end

    # 物件種別フィルタ
    if params[:property_type].present?
      properties = properties.where(property_type: params[:property_type])
    end

    # 都道府県フィルタ
    if params[:prefecture].present?
      properties = properties.where(prefecture: params[:prefecture])
    end

    # 価格範囲フィルタ（売買・賃貸の適切な価格を判定）
    if params[:min_price].present? || params[:max_price].present?
      min_price = params[:min_price].to_i if params[:min_price].present?
      max_price = params[:max_price].to_i if params[:max_price].present?

      price_conditions = []

      # 売買価格でのフィルタ（万円単位）
      if min_price.present? && max_price.present?
        price_conditions << "(sale_price BETWEEN #{min_price} AND #{max_price})"
        # 賃貸価格でのフィルタ（月額円単位）
        price_conditions << "(rental_price BETWEEN #{min_price * 10000} AND #{max_price * 10000})"
      elsif min_price.present?
        price_conditions << "(sale_price >= #{min_price})"
        price_conditions << "(rental_price >= #{min_price * 10000})"
      elsif max_price.present?
        price_conditions << "(sale_price <= #{max_price})"
        price_conditions << "(rental_price <= #{max_price * 10000})"
      end

      if price_conditions.any?
        properties = properties.where(price_conditions.join(' OR '))
      end
    end

    properties
  end

  # ソート順を適用
  def apply_sort_order(properties)
    case params[:sort]
    when 'price_asc'
      # 価格安い順（売買価格優先、次に賃貸価格）
      properties.order(
        Arel.sql("CASE WHEN sale_price IS NOT NULL THEN sale_price ELSE rental_price / 10000 END ASC")
      )
    when 'price_desc'
      # 価格高い順（売買価格優先、次に賃貸価格）
      properties.order(
        Arel.sql("CASE WHEN sale_price IS NOT NULL THEN sale_price ELSE rental_price / 10000 END DESC")
      )
    when 'updated_at_desc'
      # 更新日順
      properties.order(updated_at: :desc)
    else
      # デフォルト：新着順
      properties.order(created_at: :desc)
    end
  end
end
