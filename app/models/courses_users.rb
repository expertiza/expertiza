class CoursesUsers < ActiveRecord::Base

  def email(pw, home_page)
    user = User.find_by_id(self.user_id)
    course = Course.find_by_id(self.course_id)
    Pgmailer.deliver_message(
            {:recipients => user.email,
             :subject => "You have been registered as a participant in #{course.title}",
             :body => {  
              :home_page => home_page,  
              :user_name => ApplicationHelper::get_user_first_name(user),
              :name =>user.name,
              :password =>pw,
              :partial_name => "register"
             }
            }
    )   
  end

end
