class Admin::PropertiesController < AdminController
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  # 物件一覧
  def index
    @properties = Property.includes(:user, :favorites).order(created_at: :desc)
    
    # 検索機能
    if params[:search].present?
      @properties = @properties.where("title LIKE ? OR description LIKE ? OR location LIKE ?", 
                                     "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # ステータスでフィルタ
    if params[:status].present? && params[:status] != 'all'
      @properties = @properties.where(status: params[:status])
    end
    
    # 物件タイプでフィルタ
    if params[:property_type].present? && params[:property_type] != 'all'
      @properties = @properties.where(property_type: params[:property_type])
    end
    
    # 価格範囲でフィルタ
    if params[:price_min].present?
      @properties = @properties.where('price >= ?', params[:price_min])
    end
    if params[:price_max].present?
      @properties = @properties.where('price <= ?', params[:price_max])
    end
    
    # ページネーション
    @properties = @properties.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total_count: Property.count,
      active_count: Property.where(status: :active).count,
      completed_count: Property.where(status: :completed).count,
      paused_count: Property.where(status: :paused).count,
      today_posts: Property.where('created_at >= ?', Date.current.beginning_of_day).count,
      house_count: Property.where(property_type: :house).count,
      land_count: Property.where(property_type: :land).count,
      apartment_count: Property.where(property_type: :apartment).count
    }
  end

  # 物件詳細
  def show
    @property_favorites = @property.favorites.includes(:user).order(created_at: :desc).limit(10)
    @property_conversations = @property.conversations.includes(:messages, :participants).order(updated_at: :desc).limit(10)
    @property_messages = Message.joins(:conversation).where(conversations: { property: @property }).includes(:sender).order(created_at: :desc).limit(10)
    
    # 統計情報
    @property_stats = {
      favorites_count: @property.favorites.count,
      conversations_count: @property.conversations.count,
      messages_count: Message.joins(:conversation).where(conversations: { property: @property }).count,
      views_count: 0 # 将来的にビュー数トラッキングを実装
    }
  end

  # 物件編集
  def edit
  end

  # 物件更新
  def update
    if @property.update(property_params)
      redirect_to admin_property_path(@property), notice: '物件情報が正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 物件削除
  def destroy
    # 関連データの削除確認
    related_data = {
      favorites: @property.favorites.count,
      conversations: @property.conversations.count,
      messages: Message.joins(:conversation).where(conversations: { property: @property }).count
    }
    
    if related_data.values.sum > 0 && !params[:force_delete]
      redirect_to admin_property_path(@property), 
                  alert: "この物件には関連データがあります。削除する場合は、関連データも一緒に削除されます。"
      return
    end
    
    # 物件と関連データを削除
    begin
      ActiveRecord::Base.transaction do
        # メッセージを先に削除
        Message.joins(:conversation).where(conversations: { property: @property }).destroy_all
        
        # 会話を削除
        @property.conversations.destroy_all
        
        # お気に入りを削除
        @property.favorites.destroy_all
        
        # 物件を削除
        @property.destroy!
      end
      
      redirect_to admin_properties_path, notice: '物件が正常に削除されました。'
    rescue => e
      redirect_to admin_property_path(@property), alert: "物件の削除に失敗しました: #{e.message}"
    end
  end

  # 物件のステータス変更
  def toggle_status
    @property = Property.find(params[:id])
    
    new_status = case params[:status]
                when 'activate' then 'active'
                when 'complete' then 'completed'
                when 'pause' then 'paused'
                else @property.status
                end
    
    if @property.update(status: new_status)
      status_name = case new_status
                   when 'active' then '募集中'
                   when 'completed' then '成約済み'
                   when 'paused' then '一時停止'
                   else new_status
                   end
      redirect_to admin_property_path(@property), notice: "物件ステータスを「#{status_name}」に変更しました。"
    else
      redirect_to admin_property_path(@property), alert: 'ステータスの更新に失敗しました。'
    end
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def property_params
    params.require(:property).permit(:title, :description, :price, :location, :property_type, :status)
  end
end