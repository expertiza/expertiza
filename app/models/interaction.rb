class Interaction < ActiveRecord::Base
  belongs_to  :participant, :class_name => 'AssignmentParticipant', :foreign_key => 'assignment_id'
  belongs_to  :team, :class_name => 'Team', :foreign_key => 'team_id'

end
