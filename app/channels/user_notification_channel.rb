class UserNotificationChannel < ApplicationCable::Channel
  def subscribed
    user_id = params[:user_id]
    
    if current_user&.id == user_id.to_i
      stream_from "user_notifications_#{user_id}"
      Rails.logger.info "User #{current_user.id} subscribed to notifications"
    else
      reject
      Rails.logger.warn "User #{current_user&.id} unauthorized for user notifications #{user_id}"
    end
  end

  def unsubscribed
    Rails.logger.info "User #{current_user&.id} unsubscribed from notifications"
  end
end