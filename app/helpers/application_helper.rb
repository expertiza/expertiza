# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def self.get_user_role(l_user)
    user = nil
    
    ## Mrunal will convert this to use reflection
    case l_user.role_id
      when Role::STUDENT  
        user = Student.new
      when Role::INSTRUCTOR 
        user = Instructor.new 
      when Role::ADMINISTRATOR
        user = Administrator.new
      when Role::SUPERADMINISTRATOR
        user = SuperAdministrator.new
    end
    user
  end
end
