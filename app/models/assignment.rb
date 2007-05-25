class Assignment < ActiveRecord::Base
  belongs_to :course 
  belongs_to :user, :foreign_key => "instructor_id"
  has_many :participants
  has_many :users, :through => :participants
  has_many :due_dates
end
