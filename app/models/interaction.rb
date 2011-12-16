class Interaction < ActiveRecord::Base
  belongs_to  :participant, :class_name => 'AssignmentParticipant', :foreign_key => 'assignment_id'
  belongs_to  :team, :class_name => 'Team', :foreign_key => 'team_id'

  validates_presence_of :number_of_minutes, :message =>'Number of minutes is blank.'
  validates_presence_of :comments, :message => "Please enter comments."
  validates_presence_of :interaction_datetime, :message => "Please enter date and time."

  validates_numericality_of :number_of_minutes, :minimum => 0, :message => "Number of minutes is blank or non-numeric."

end
