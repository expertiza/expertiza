class MentoredTeam < AssignmentTeam
    # Class created during refactoring of E2351
    # Overridden method to include the MentorManagement workflow
    def add_member(user, _assignment_id = nil)
        raise "The user #{user.name} is already a member of the team #{name}" if user?(user)
        return false unless !full?
        
        add_user_to_team(user)
        ExpertizaLogger.info LoggerMessage.new('Model:Team', user.name, "Added member to the team #{id}")
        MentorManagement.assign_mentor(_assignment_id, id)
        true
    end

    private 

    def add_user_to_team(user)
        t_user = TeamsUser.create(user_id: user.id, team_id: id)
        parent = TeamNode.find_by(node_object_id: id)
        TeamUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
        add_participant(parent.id, user)
    end
end
