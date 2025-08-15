class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # ユーザー一覧
  def index
    @users = User.all.order(created_at: :desc)
    
    # 検索機能
    if params[:search].present?
      @users = @users.where("name LIKE ? OR email LIKE ?", 
                           "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # ユーザータイプでフィルタ
    if params[:user_type].present? && params[:user_type] != 'all'
      @users = @users.where(user_type: params[:user_type])
    end
    
    # ページネーション
    @users = @users.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total_count: User.count,
      buyer_count: User.buyer.count,
      owner_count: User.owner.count,
      admin_count: User.admin.count,
      today_registrations: User.where('created_at >= ?', Date.current.beginning_of_day).count
    }
  end

  # ユーザー詳細
  def show
    @user_properties = @user.properties.includes(:favorites).order(created_at: :desc).limit(10)
    @user_conversations = @user.conversations.includes(:property, :messages).order(updated_at: :desc).limit(10)
    @user_messages = @user.sent_messages.includes(:conversation).order(created_at: :desc).limit(10)
    @user_favorites = @user.favorites.includes(:property).order(created_at: :desc).limit(10)
    
    # 統計情報
    @user_stats = {
      properties_count: @user.properties.count,
      conversations_count: @user.conversations.count,
      sent_messages_count: @user.sent_messages.count,
      favorites_count: @user.favorites.count,
      login_count: 0 # 将来的にログイン回数トラッキングを実装
    }
  end

  # ユーザー編集
  def edit
  end

  # ユーザー更新
  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'ユーザー情報が正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # ユーザー削除
  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: '自分自身を削除することはできません。'
      return
    end
    
    # 関連データの削除確認
    related_data = {
      properties: @user.properties.count,
      conversations: @user.conversations.count,
      messages: @user.sent_messages.count,
      favorites: @user.favorites.count
    }
    
    if related_data.values.sum > 0 && !params[:force_delete]
      redirect_to admin_user_path(@user), 
                  alert: "このユーザーには関連データがあります。削除する場合は、関連データも一緒に削除されます。"
      return
    end
    
    # ユーザーと関連データを削除
    begin
      ActiveRecord::Base.transaction do
        # 関連データを先に削除
        @user.favorites.destroy_all
        @user.sent_messages.destroy_all
        @user.received_messages.destroy_all
        @user.conversations.destroy_all
        @user.properties.destroy_all
        @user.destroy!
      end
      
      redirect_to admin_users_path, notice: 'ユーザーが正常に削除されました。'
    rescue => e
      redirect_to admin_user_path(@user), alert: "ユーザーの削除に失敗しました: #{e.message}"
    end
  end

  # ユーザーの一時停止/復活
  def toggle_status
    @user = User.find(params[:id])
    
    # 仮のステータス管理（将来的にactive/inactiveカラムを追加）
    if @user.update(updated_at: Time.current)
      status = params[:status] == 'activate' ? '有効化' : '一時停止'
      redirect_to admin_user_path(@user), notice: "ユーザーを#{status}しました。"
    else
      redirect_to admin_user_path(@user), alert: 'ステータスの更新に失敗しました。'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :user_type)
  end
end