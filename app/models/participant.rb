class Participant < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :resubmission_times 

  def get_topic_string
    if topic == nil or topic.strip == ""
      return "<center>&#8212;</center>"
    end
    return topic
  end
  
  def get_course_string
    # if no course is associated with this assingment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if assignment.course == nil or assignment.course.title == nil or assignment.course.title.strip == ""
      return "<center>&#8212;</center>"
    end
    return assignment.course.title
  end
  
  def able_to_submit
    if submit_allowed
      return true
    end
    return false
  end
  
  def able_to_review
    if review_allowed
      return true
    end
    return false
  end
  
  def email(pw, home_page)
    user = User.find_by_id(self.user_id)
    assignment = Assignment.find_by_id(self.assignment_id)
    Pgmailer.deliver_message(
            {:recipients => user.email,
             :subject => "You have been registered as a participant in Assignment #{assignment.name}",
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
