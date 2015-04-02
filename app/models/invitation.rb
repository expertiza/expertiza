class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"

  def self.remove_waitlists_for_team(topic_id, assignment_id)
    first_waitlisted_signup = SignedUpUser.where(topic_id: topic_id, is_waitlisted:  true).first

    #As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
    first_waitlisted_signup.is_waitlisted = false
    first_waitlisted_signup.save

    #Update the Participant Table first_waitlisted_signup.creator_id is the team id so find one
    #of the users on the new team
    user_id = TeamsUser.first_by_team_id(first_waitlisted_signup.creator_id).user_id
    #Obtain this users entry in the participants table for this assignment
    participant = Participant.where(user_id: user_id, parent_id:  assignment_id).first
    #Update the users topic id to that of the team they are joining in the Participants table
    participant.update_topic_id(topic_id)
    #Cancel all topics the user is waitlisted for
    SignUpTopic.cancel_all_waitlists(first_waitlisted_signup.creator_id, SignUpTopic.find(topic_id).assignment_id)
  end

  #Remove all invites sent by a user for an assignment.
  def self.remove_users_sent_invites_for_assignment(user_id, assignment_id)
    invites = Invitation.where(['from_id = ? and assignment_id = ?', user_id, assignment_id])
    for invite in invites
      invite.destroy
    end
  end

  #After a users accepts an invite to join a team their topic id needs to be updated.
  def self.update_users_topic_after_invite_accept(invitee_user_id, invited_user_id, assignment_id)
    participant = Participant.where(user_id: invited_user_id, parent_id:  assignment_id).first
    #Find the topic id that the user who sent the invite is assigned to
    new_topic_id = Participant.where(user_id: invitee_user_id, parent_id:  assignment_id).first.topic_id
    #Update topic id of users who accepted the invite
    participant.update_topic_id(new_topic_id)
  end

  #This method handles all that needs to be done upon a user accepting an invite.
  #First the users previous team is deleted if they were the only member of that
  #team and topics that the old team signed up for will be deleted.
  #Then invites the user that accepted the invite sent will be removed.
  #Last the users team entry will be added to the TeamsUser table and their assigned topic is updated
  def self.accept_invite(team_id, invitee_user_id, invited_user_id, assignment_id)
    #if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    if TeamsUser.is_team_empty(team_id) and team_id != '0'
      assignment_id = AssignmentTeam.find(team_id).assignment.id
      #Release topics for the team has selected by the invited users empty team
      SignedUpUser.release_topics_selected_by_team_for_assignment(team_id, assignment_id)

      AssignmentTeam.remove_team_by_id(team_id)
    end

    #If you change your team, remove all your invitations that you send to other people
    Invitation.remove_users_sent_invites_for_assignment(invited_user_id, assignment_id)

    #Create a new team_user entry for the accepted invitation
    @team_user = TeamsUser.new
    can_add_member = TeamsUser.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)

    if can_add_member        # The member was successfully added to the team (the team was not full)
      Invitation.update_users_topic_after_invite_accept(invitee_user_id, invited_user_id, assignment_id)
    end

    return can_add_member
  end

  def self.is_invited?(invitee_user_id, invited_user_id, assignment_id)
    sent_invitation = Invitation.where(['from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"', invitee_user_id, invited_user_id, assignment_id])
    if sent_invitation.length == 0
      return true
    end
    return false
  end
end
