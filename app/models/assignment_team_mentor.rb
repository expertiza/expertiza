class AssignmentTeamMentor < ActiveRecord::Base
  belongs_to :team
  belongs_to :participant

  validates :assignment_team_id, presence: true
  validates :assignment_team_mentor_id, presence: true

  def assignMentor(assignment_id)
    list = Participant.getPotentialMentors(assignment_id)
    if list.count < 1
      # Add code for when no tas or instructor have been added as a participant to current assignent
      raise StandardError, "No participant mentors have been added to this assignment. Unable to assign mentor to latest team created."
    else
      # Hash to find current mentors assigned for current assignment. Keys of hash will be participant_ids and values are count of times 
      # an id has been assigned to teams created for current assignment
      currentAssignedTeamMentors = {}
      list.each { |p| teamAssignedCount = AssignmentTeamMentor.where(assignment_team_mentor_id: p.id).count
      currentAssignedTeamMentors[p.id] = teamAssignedCount
      }
      currentAssignedTeamMentorsArray = currentAssignedTeamMentors.sort_by{ |id, teamsMentoredCount| teamsMentoredCount }
      # Assign assignment_team_mentor_id 
      self.assignment_team_mentor_id = currentAssignedTeamMentorsArray.first.first
    end
  end 
end
