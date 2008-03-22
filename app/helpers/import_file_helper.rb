require 'csv'

module ImportFileHelper
 
  def self.define_attributes(row)   
    attributes = {}
    attributes["role_id"] = Role.find_by_name "Student"
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["clear_password"] = row[3].strip
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session,logger)
    user = User.new(attributes)
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


