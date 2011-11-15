# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def is_available(user,owner_id)
    if user.id == owner_id
      return true
    elsif user.role.name == 'Administrator' or
       user.role.name == 'Super-Administrator'
       return true
    else
       return false
    end
  end
  
  def self.get_user_role(l_user)
    user = nil
    
    ## Mrunal will convert this to use reflection
    case l_user.role_id
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
      when Role::STUDENT  
        user = Student.new
      when Role::TA
        user = Ta.new 
      when Role::INSTRUCTOR 
        user = Instructor.new 
      when Role::ADMINISTRATOR
        user = Administrator.new
      when Role::SUPERADMINISTRATOR
<<<<<<< HEAD
=======
=======
=======
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
      when Role.student.id  
        user = Student.new
      when Role.ta.id
        user = Ta.new 
      when Role.instructor.id 
        user = Instructor.new 
      when Role.administrator.id
        user = Administrator.new
      when Role.superadministrator.id
<<<<<<< HEAD
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
        user = SuperAdministrator.new
    end
    user
  end
  
  def self.get_user_first_name(recipient)
    return '' if recipient.fullname.blank?
    if recipient.fullname.index(",")
      start_ss = recipient.fullname.index(",")+2
    else
      start_ss = 0
    end   
    name = recipient.fullname[start_ss, recipient.fullname.length]
    return name.strip
 end
 
  def self.get_field(element,field,model,column)   
    item = Object.const_get(model).find(element[column.to_sym])
    return item[field.to_sym]
  end 
end
