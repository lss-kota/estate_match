class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer!
  before_action :set_property, only: [:create, :destroy]

  # POST /favorites
  def create
    @favorite = current_user.favorites.build(property: @property)
    
    if @favorite.save
      render json: { 
        status: 'success', 
        message: 'お気に入りに追加しました',
        favorited: true,
        favorites_count: @property.favorites_count
      }
    else
      render json: { 
        status: 'error', 
        message: 'お気に入りの追加に失敗しました' 
      }, status: :unprocessable_entity
    end
  end

  # DELETE /properties/:property_id/favorite
  def destroy
    @favorite = current_user.favorites.find_by(property: @property)
    
    if @favorite&.destroy
      render json: { 
        status: 'success', 
        message: 'お気に入りから削除しました',
        favorited: false,
        favorites_count: @property.favorites_count
      }
    else
      render json: { 
        status: 'error', 
        message: 'お気に入りの削除に失敗しました' 
      }, status: :not_found
    end
  end

  # GET /favorites
  def index
    @favorite_properties = current_user.favorite_properties
                                      .includes(:user, :tags, images_attachments: :blob)
                                      .where(status: :active)
                                      .order(created_at: :desc)
                                      .limit(20)
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def ensure_buyer!
    unless current_user.buyer?
      if request.xhr? || params[:format] == 'json'
        render json: { 
          status: 'error', 
          message: '購入希望者のみ利用可能な機能です' 
        }, status: :forbidden
      else
        redirect_to root_path, alert: '購入希望者のみ利用可能な機能です'
      end
    end
  end
end