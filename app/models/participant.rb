class Participant < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :resubmission_times 
  
  validates_numericality_of :grade, :allow_nil => true

  def get_topic_string
    if topic == nil or topic.strip == ""
      return "<center>&#8212;</center>"
    end
    return topic
  end
  
  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if assignment.course == nil or assignment.course.title == nil or assignment.course.title.strip == ""
      return "<center>&#8212;</center>"
    end
    return assignment.course.title
  end
  
  def get_scenario_string
    if assignment.spec_location == nil
      return "<center>&#8212;</center>"      
    end
    return "<a href=\"" + assignment.spec_location + "\" target=\"new\"/>View</A>"
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

    Mailer.deliver_message(
            {:recipients => user.email,
             :subject => "You have been registered as a participant in Assignment #{assignment.name}",
             :body => {  
              :home_page => home_page,  
              :first_name => ApplicationHelper::get_user_first_name(user),
              :name =>user.name,
              :password =>pw,
              :partial_name => "register"
             }
            }
    )   
  end
    
  

  def self.import(row,session)
      if row.length == 4
        user = User.find_by_name(row[0])        
        if (user == nil)
          attributes = ImportFileHelper::define_attributes(row)
          user = ImportFileHelper::create_new_user(attributes,session,logger)
        end      
        if (session[:assignment_id] != nil)
          ImportFileHelper::add_user_to_assignment(session[:assignment_id], user)
        end
        if (session[:course_id] != nil)
          ImportFileHelper::add_user_to_course(session[:course_id], user)
        end
      else
        raise ArgumentError, "Not enough items" 
      end    
  end
  
  protected
  def validate
    #need to find a way to only validate this when it is called
    #from a certain controller or action. For example, we only
    #want this validated when save_final_grade is called from the 
    #student_assignment controller
    #errors.add(:grade, "should be greater or equal to zero") if grade < 0
  end
end