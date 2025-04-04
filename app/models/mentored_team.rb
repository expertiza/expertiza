class MentoredTeam < AssignmentTeam
  # Class created during refactoring of E2351
  # Overridden method to include the MentorManagement workflow
  def add_member(participant, _assignment_id = nil)
      raise "The participant #{participant.user.name} is already a member of the team #{name}" if user?(participant.user)
  
      can_add_member = false
      unless full?
        can_add_member = true
        t_participant = TeamsParticipant.create(participant_id: participant.id, team_id: id)
        parent = TeamNode.find_by(node_object_id: id)
        TeamUserNode.create(parent_id: parent.id, node_object_id: t_participant.id)
        add_participant(parent_id, participant.user)
        ExpertizaLogger.info LoggerMessage.new('Model:Team', participant.user.name, "Added member to the team #{id}")
      end
      if can_add_member
          MentorManagement.assign_mentor(_assignment_id, id)
      end
      can_add_member
  end

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

  def create_new_team(user_id, signuptopic)
    t_participant = TeamsParticipant.create(team_id: id, participant_id: user_id)
    SignedUpTeam.create(topic_id: signuptopic.id, team_id: id, is_waitlisted: 0)
    parent = TeamNode.create(parent_id: signuptopic.assignment_id, node_object_id: id)
    TeamUserNode.create(parent_id: parent.id, node_object_id: t_participant.id)
  end
end
