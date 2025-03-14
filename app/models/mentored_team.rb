class MentoredTeam < AssignmentTeam
  # Adds a member to the team and assigns a mentor (if applicable).
  def add_member(user, assignment_id = nil)
    can_add_member = super(user)
    if can_add_member
      MentorManagement.assign_mentor(assignment_id, id)
    end
    can_add_member
  end

  # Imports team members from the provided row hash and assigns mentors if necessary.
  def import_team_members(row_hash)
    row_hash[:teammembers].each_with_index do |teammate, _index|
      if teammate.to_s.strip.empty?
        next
      end
      user = User.find_by(name: teammate.to_s)
      if user.nil?
        raise ImportError, "The user '#{teammate}' was not found. <a href='/users/new'>Create</a> this user?"
      else
        add_member(user, parent_id) if TeamsUser.find_by(team_id: id, user_id: user.id).nil?
      end
    end
  end
end
