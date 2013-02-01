class Suggestion < ActiveRecord::Base
  validates_presence_of :title, :description
   has_many :suggestion_comments 
   
   def find_all_by_assignment_id(assignment_id)
      find(:all, :conditions => ["assignment_id = ?", assignment_id])
   end
end
