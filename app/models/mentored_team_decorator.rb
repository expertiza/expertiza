# frozen_string_literal: true

class MentoredTeamDecorator
  attr_reader :id
  def initialize(assignment_team)
    @id = assignment_team.id
    @assignment_team = assignment_team
    @assignment_team.type = "Mentored"
  end

  def add_member(user, assignment_id=nil)
    # can_add_member is true as long as the add member function is successful
    # If the mentor is already mentoring the team, can_add_member will return false
    can_add_member = @assignment_team.add_member(user, assignment_id)
    if can_add_member
      MentorManagement.assign_mentor(assignment_id, id)
    end
  end
end
