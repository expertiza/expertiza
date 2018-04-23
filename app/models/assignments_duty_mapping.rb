class AssignmentsDutyMapping < ActiveRecord::Base

	 def self.assign_duties_to_assignment(assignment_id)
    	duties = AssignmentsDutyMapping.where(assignment_id: assignment_id).pluck(:duty_id)
 	 end

end
