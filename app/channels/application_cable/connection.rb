module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "ActionCable connected: User #{current_user.id}"
    end

    private

    def find_verified_user
      # Deviseのセッションからユーザーを取得
      if (user_id = cookies.encrypted[:user_id]) && (user = User.find_by(id: user_id))
        user
      elsif (user = env['warden']&.user)
        # Wardenからユーザーを取得（通常のセッション認証）
        user
      else
        reject_unauthorized_connection
      end
    rescue
      reject_unauthorized_connection
    end
  end
end
