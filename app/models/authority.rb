class Authority
  attr_reader :current_user

  def initialize(args = {})
    @current_user = args[:current_user]
  end

  def allow?(controller, action)
    return true if current_user && current_user.admin?
    case controller
    when 'pages'
      true
    end
  end
end
