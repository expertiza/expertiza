module AuthHelper
  def self.get_home_action(user)
    begin
      # Get the correct home action from a user type class
      # For example, Student.get_home_action returns "list"
      action_name = ApplicationHelper::get_user_role(user).send(:get_home_action) 
    rescue
      # Default to the list method within the assignment controller
      action_name = "drill"
    end
    return action_name
  end
  
  def self.get_home_controller(user)
    begin
      controller_name = ApplicationHelper::get_user_role(user).send(:get_home_controller)
    rescue
      # If no get_home_controller method exists for the user then
      # default to the assignment controller
      controller_name = "tree_display"
    end
    return controller_name
  end
end
