require 'csv'

module ImportFileHelper
  
  def self.import_csv(file,session)
    CSV::Reader.parse(file) do | row |
      user = User.find_by_name(row[0])
      if (user == nil)
         attributes = define_attributes(row)
         user = create_new_user(attributes,session)
      end      
      if (session[:assignment_id] != nil)
         participant = add_user_to_assignment(session[:assignment_id], user)
      end
      if (session[:course_id] != nil)
         participant = add_user_to_course(session[:course_id], user)
      end
    end     
  end
  
  def self.define_attributes(row)   
    attributes = {}
    attributes["role_id"] = Role.find_by_name "Student"
    attributes["name"] = row[0]
    attributes["fullname"] = updateFullName(row[1])
    attributes["email"] = row[2]
    attributes["clear_password"] = row[3]
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end
  
  def self.updateFullName(name)
    sp_name = name.split
    first = sp_name[0]
    if sp_name.length == 3
      middle = sp_name[1]
      last = sp_name[2]
    else
      last = sp_name[1]
      middle = ""
    end
    
    name = last+", "+first+" "+middle
  end

  def self.create_new_user(attrs, session)
    user = User.new
    user.update_attributes attrs
    user.parent_id = (session[:user]).id
    user.save
    user 
  end
  
  def self.add_user_to_assignment(assignment_id, user)
    assignment = Assignment.find assignment_id
    if (Participant.find(:all,{:conditions => ['user_id=? AND assignment_id=?', user.id, assignment.id]}).size == 0)
      return Participant.create(:assignment_id => assignment.id, :user_id => user.id)
    end
  end
  
  def self.add_user_to_course(course_id, user)
    course = Course.find course_id
    if (CoursesUsers.find(:all, {:conditions => ['user_id=? AND course_id=?', user.id, course.id]}).size == 0)
      CoursesUsers.create :user_id => user.id, :course_id => course.id
    end
  end
end


