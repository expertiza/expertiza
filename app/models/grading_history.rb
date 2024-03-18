class GradingHistory < ApplicationRecord
  belongs_to :instructor, inverse_of: :instructor_id
  belongs_to :assignment, inverse_of: :assignment_id

  # populate the assignment fields according to type
  def self.assignment_for_history(type)
    # for a submission, the receiver is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? 'Submission'
      assignment_team = AssignmentTeam.find(params[:grade_receiver_id])
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    # for a review, the receiver is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    if type.eql? 'Review'
      participant_id = params[:participant_id]
      grade_receiver = AssignmentParticipant.find(participant_id)
      @assignment = Assignment.find(grade_receiver.parent_id)
    end
  end
end
