module AuthHelper
  def self.get_home_action(user)
    user.role.get_home_action
  rescue
    'index'
  end

  def self.get_home_controller(user)
    user.role.get_home_controller
  rescue
    'tree_display'
  end
end
