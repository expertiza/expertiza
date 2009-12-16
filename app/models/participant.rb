class Participant < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :resubmission_times 
  
  validates_numericality_of :grade, :allow_nil => true

  def name
    User.find(self.user_id).name
  end
  
  def fullname
    User.find(self.user_id).fullname
  end 

  def delete
    times = ResubmissionTime.find(:all, :conditions => ['participant_id = ?',self.id])
    times.each {|time| time.destroy }
    self.destroy
  end

  def get_topic_string
    if topic == nil or topic.strip == ""
      return "<center>&#8212;</center>"
    end
    return topic
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
end