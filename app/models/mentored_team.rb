class MentoredTeam < AssignmentTeam
    # Class created during refactoring of E2351
    # Overridden method to include the MentorManagement workflow
    def add_member(user, _assignment_id = nil)
        raise "The user #{user.username} is already a member of the team #{name}" if user?(user)
    
        can_add_member = false
        unless full?
          can_add_member = true
          t_user = TeamsUser.create(user_id: user.id, team_id: id)
          parent = TeamNode.find_by(node_object_id: id)
          TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
          add_participant(parent_id, user)
          ExpertizaLogger.info LoggerMessage.new('Model:Team', user.username, "Added member to the team #{id}")
        end
        if can_add_member
            MentorManagement.assign_mentor(_assignment_id, id)
        end
        can_add_member
    end
end
