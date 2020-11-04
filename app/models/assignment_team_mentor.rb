class AssignmentTeamMentor < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :assignment_team_id, presence: true
  validates :assignment_team_mentor_id, presence: true

  def assignMentor(parent_id)
    list = Participant.getPotentialMentors(parent_id)
    if list.count < 1
      # Add code for when no tas or instructor have been added as a participant to current assignent
      raise AssignmentTeamMentorError, "No participant mentors have been added to this assignment. Unable to assign mentor to latest team created."
    else
      currentAssignedTeamMentors = {}
      list.each { |p| teamAssignedCount = AssignmentTeamMentor.where(assignment_team_mentor_id: p.user_id).count
      currentAssignedTeamMentors[p.user_id] = teamAssignedCount 
      }
      currentAssignedTeamMentorsArray = currentAssignedTeamMentors.sort_by{ |user_id, teamsMentoredCount| teamsMentoredCount }
      self.assignment_team_mentor_id = currentAssignedTeamMentorsArray.first.first
    end
  end 
end
