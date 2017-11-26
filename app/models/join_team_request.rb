class JoinTeamRequest < ActiveRecord::Base
  belongs_to :team
  has_one :participant

  def self.accept_invite(team_id, inviter_user_id, invited_user_id, assignment_id)

    # if you are on a team and you accept another invitation and if your old team does not have any members, delete the entry for the team
    if TeamsUser.is_team_empty(team_id) and team_id != '0'
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

      invited_participant = Participant.where(user_id: invited_user_id, parent_id: assignment_id).first
      inviter_participant = Participant.where(user_id: inviter_user_id, parent_id: assignment_id).first
      inviter_assignment_team = AssignmentTeam.team(inviter_participant)
    end

    can_add_member
  end





end
