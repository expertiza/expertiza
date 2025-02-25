module TeamsHelper
  def get_participants_without_team(assignment)
    assignment.max_team_size > 1 ? assignment.participants.select { |p| AssignmentTeam.team(p).nil? } : []
  end
end
