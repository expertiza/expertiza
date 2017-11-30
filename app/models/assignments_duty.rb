class AssignmentsDuty < ActiveRecord::Base
  def self.duties_by_assignment(assignment_id)
    duties = AssignmentsDuty.where(assignment_id: assignment_id).pluck(:duty_id)
  end
end
