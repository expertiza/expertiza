class InteractionWeight < ActiveRecord::Base
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'assignment_id'
end
