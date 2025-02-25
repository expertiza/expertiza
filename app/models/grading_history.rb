class GradingHistory < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :assignment

  # populate the assignment fields according to type
  def self.assignment_for_history(type, graded_member_id, participant_id)
    # for a submission, the graded party is an AssignmentTeam
    # use this AssignmentTeam to find the assignment
    if type.eql? 'Submission'
      assignment_team = AssignmentTeam.find(graded_member_id)
      return Assignment.find(assignment_team.parent_id)
    end
    # for a review, the graded party is an AssignmentParticipant
    # use this AssignmentParticipant to find the assignment
    if type.eql? 'Review'
      graded_member = AssignmentParticipant.find(participant_id)
      return ReviewGrade.find_graded_member(graded_member)
    end
  end
end
