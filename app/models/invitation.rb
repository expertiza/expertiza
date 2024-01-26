class Invitation < ApplicationRecord
  # belongs_to :to_user, class_name: "User", foreign_key: "to_id"
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_id', inverse_of: false
  # belongs_to :from_user, class_name: "User", foreign_key: "from_id"
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_id', inverse_of: false

  def self.remove_waitlists_for_team(topic_id, _assignment_id)
    # first_waitlisted_signup = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
    first_waitlisted_signup = SignedUpTeam.find_by(topic_id: topic_id, is_waitlisted: true)

    # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
    first_waitlisted_signup.is_waitlisted = false
    first_waitlisted_signup.save

    # Cancel all topics the user is waitlisted for
    Waitlist.cancel_all_waitlists(first_waitlisted_signup.team_id, SignUpTopic.find(topic_id).assignment_id)
  end

  # Remove all invites sent by a user for an assignment.
  def self.remove_users_sent_invites_for_assignment(user_id, assignment_id)
    invites = Invitation.where('from_id = ? and assignment_id = ?', user_id, assignment_id)
    invites.each(&:destroy)
  end

  # After a users accepts an invite, the teams_users table needs to be updated.
  def self.update_users_topic_after_invite_accept(invitee_user_id, invited_user_id, assignment_id)
    new_team_id = TeamsUser.team_id(assignment_id, invitee_user_id)
    # check the invited_user_id have ever join other team in this assignment before
    # if so, update the original record; else create a new record
    original_team_id = TeamsUser.team_id(assignment_id, invited_user_id)
    if original_team_id
      # team_user_mapping = TeamsUser.where(team_id: original_team_id, user_id: invited_user_id).first
      team_user_mapping = TeamsUser.find_by(team_id: original_team_id, user_id: invited_user_id)
      TeamsUser.update(team_user_mapping.id, team_id: new_team_id)
    else
      TeamsUser.create(team_id: new_team_id, user_id: invited_user_id)
    end
  end

  # This method handles all that needs to be done upon a user accepting an invitation.
  # First the users previous team is deleted if they were the only member of that
  # team and topics that the old team signed up for will be deleted.
  # Then invites the user that accepted the invite sent will be removed.
  # Last the users team entry will be added to the TeamsUser table and their assigned topic is updated
  def self.accept_invitation(team_id, inviter_user_id, invited_user_id, assignment_id)
    # if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    if TeamsUser.team_empty?(team_id) && (team_id != '0')
      assignment_id = AssignmentTeam.find(team_id).assignment.id
      # Release topics for the team has selected by the invited users empty team
      SignedUpTeam.release_topics_selected_by_team_for_assignment(team_id, assignment_id)
      AssignmentTeam.remove_team_by_id(team_id)
    end

    # If you change your team, remove all your invitations that you send to other people
    Invitation.remove_users_sent_invites_for_assignment(invited_user_id, assignment_id)

    # Create a new team_user entry for the accepted invitation
    @team_user = TeamsUser.new
    can_add_member = TeamsUser.add_member_to_invited_team(inviter_user_id, invited_user_id, assignment_id)

    if can_add_member # The member was successfully added to the team (the team was not full)
      Invitation.update_users_topic_after_invite_accept(inviter_user_id, invited_user_id, assignment_id)

      # E2115 Mentor Management
      # Kick off the Mentor Management workflow
      # Since there are two places in the code base where members are added to
      # teams we have to call the MentorManagement class in both places.
      # Those places are here when a student accepts an invitation to join a
      # team, and in teams_users_controller.rb. Ideally, both code paths would
      # call the same method to perform this action and we could DRY this up.
      # It is worth noting that while ultimately, both code paths do call Team#add_member
      # adding this code there would risk a recursive loop since MentorManagement
      # also calls Team#add_member to add a mentor to the team
      new_team_id = TeamsUser.team_id(assignment_id, inviter_user_id)
      MentorManagement.assign_mentor(assignment_id, new_team_id)

      # invited_participant = Participant.where(user_id: invited_user_id, parent_id: assignment_id).first
      # inviter_participant = Participant.where(user_id: inviter_user_id, parent_id: assignment_id).first
      # inviter_assignment_team = AssignmentTeam.team(inviter_participant)
    end

    can_add_member
  end

  def self.is_invited?(invitee_user_id, invited_user_id, assignment_id)
    sent_invitation = Invitation.where('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       invitee_user_id, invited_user_id, assignment_id)
    sent_invitation.empty?
  end
end
