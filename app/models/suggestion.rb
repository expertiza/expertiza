class Suggestion < ActiveRecord::Base
  validates_presence_of :title, :description
   has_many :suggestion_comments 
   has_many :suggestion_logs
   
   def find_all_by_assignment_id(assignment_id)
      find(:all, :conditions => ["assignment_id = ?", assignment_id])
  end
  
    # Generate emails for reviewers when new content is available for review
  #ajbudlon, sept 07, 2007   
  def email(user_id, editor) 
  
    # Get all review mappings for this assignment & author
    user = User.find(user_id)
  
     if user.email_on_review
        Mailer.deliver_message(
          {:recipients => user.email,
           :subject => "Suggested topic has been edited by #{editor}",
           :body => {
            :obj_name => self.title,
            :type => "suggestion",
            :location => self.id,
            :first_name => ApplicationHelper::get_user_first_name(user),
            :partial_name => "update"
           }
          }
        )
     end
  end 

end
