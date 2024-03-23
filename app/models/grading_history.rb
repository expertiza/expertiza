class GradingHistory < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :assignment

  # populate the assignment fields according to type
  def assignment_for_history(type, assignment_team, participant_id)
    # for a submission, the receiver is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? 'Submission'
      @assignment = Assignment.find(assignment_team.parent_id)
    end
    # for a review, the receiver is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    if type.eql? 'Review'
      graded_member = AssignmentParticipant.find(participant_id)
      @assignment = ReviewGrade.find_graded_member(graded_member)
    end
  end
end