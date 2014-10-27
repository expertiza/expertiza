# == Schema Information
#
# Table name: suggestions
#
#  id                :integer          not null, primary key
#  assignment_id     :integer
#  title             :string(255)
#  description       :text
#  status            :string(255)
#  unityID           :string(255)
#  signup_preference :string(255)
#

class Suggestion < ActiveRecord::Base
  validates_presence_of :title, :description
   has_many :suggestion_comments 
   
   def find_all_by_assignment_id(assignment_id)
      find(:all, :conditions => ["assignment_id = ?", assignment_id])
   end
end
