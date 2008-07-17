class Participant < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  has_many :resubmission_times 
  
  validates_numericality_of :grade, :allow_nil => true

  def delete
    times = ResubmissionTime.find(:all, :conditions => ['participant_id = ?',self.id])
    times.each {|time| time.destroy }
  end

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

  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)
    if row.length != 4
       raise ArgumentError, "Not enough items" 
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end              
    assignment = Assignment.find(id)
    if assignment == nil
       raise ImportError, "The assignment with id \""+id.to_s+"\" was not found."
    end
    if (Participant.find(:all, {:conditions => ['user_id=? AND assignment_id=?', user.id, assignment.id]}).size == 0)
       Participant.create(:user_id => user.id, :assignment_id => assignment.id)
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