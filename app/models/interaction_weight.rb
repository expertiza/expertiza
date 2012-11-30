class InteractionWeight < ActiveRecord::Base
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'assignment_id'

  validates_presence_of :max_score, :message=>"Maximum score cant be blank"
  validates_presence_of :weight, :message=>"Weight cant be blank"
end
