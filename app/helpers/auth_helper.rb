module AuthHelper
  def self.get_home_action(user)
    Rails::logger.info "BLAST_ACTION-----------------------------------"
    Rails::logger.info "user.role.get_home_action =#{user.role.get_home_action}"
    user.role.get_home_action
  rescue
    Rails::logger.info "BLAST_DRILL-----------------------------------"
    'drill'
  end

  def self.get_home_controller(user)
    Rails::logger.info "BLAST_CONTROLLER-----------------------------------"
    Rails::logger.info "user.role.get_home_controller =#{user.role.get_home_controller}"
    user.role.get_home_controller
    Rails::logger.info "user.role.get_home_controller =#{user.role.get_home_controller}"
  rescue
    Rails::logger.info "BLAST_TREE-----------------------------------"
    'tree_display'
  end
end
