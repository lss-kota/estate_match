class MyPropertiesController < ApplicationController
  before_action :ensure_owner!

  def index
    @properties = current_user.properties
                             .includes(:tags, images_attachments: :blob)
                             .order(created_at: :desc)
  end

  private

  def ensure_owner!
    unless current_user.owner?
      redirect_to dashboard_path, alert: 'オーナーのみ利用可能な機能です。'
    end
  end
end
