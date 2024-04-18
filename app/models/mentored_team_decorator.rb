# frozen_string_literal: true

class MentoredTeamDecorator
  def initialize(assignment_team)
    @assignment_team = assignment_team
  end

  def add_member(user, assignment_id=nil)
    can_add_member = @assignment_team.add_member(user, assignment_id)
    if can_add_member
      MentorManagement.assign_mentor(assignment_id, id)
    end
  end
end
