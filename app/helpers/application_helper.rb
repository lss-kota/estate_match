module ApplicationHelper
  def user_type_display(user)
    case user.user_type
    when 'buyer'
      '購入希望者'
    when 'owner'
      '物件オーナー'
    when 'agent'
      '不動産業者'
    when 'admin'
      '管理者'
    else
      'Unknown'
    end
  end
  
  def user_type_badge_class(user)
    case user.user_type
    when 'buyer'
      'bg-estate-success-100 text-estate-success-600'
    when 'owner'
      'bg-estate-gold-100 text-estate-gold-600'
    when 'agent'
      'bg-blue-100 text-blue-600'
    when 'admin'
      'bg-red-100 text-red-600'
    else
      'bg-gray-100 text-gray-600'
    end
  end
end
