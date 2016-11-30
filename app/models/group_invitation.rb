class GroupInvitation < ActiveRecord::Base
  belongs_to :to_user, class_name: "User", foreign_key: "to_id"
  belongs_to :from_user, class_name: "User", foreign_key: "from_id"

  # Remove all invites sent by a user for an assignment.
  def self.remove_users_sent_invites_for_assignment(user_id, assignment_id)
    invites = GroupInvitation.where(['from_id = ? and assignment_id = ?', user_id, assignment_id])
    for invite in invites
      invite.destroy
    end
  end

  # After a users accepts an invite, the group_users table needs to be updated.
  def self.update_users_topic_after_invite_accept(invitee_user_id, invited_user_id, assignment_id)
    new_group_id = GroupsUser.group_id(assignment_id, invitee_user_id)
    # check the invited_user_id have ever join other group in this assignment before
    # if so, update the original record; else create a new record
    original_group_id = GroupsUser.group_id(assignment_id, invited_user_id)
    if original_group_id
      group_user_mapping = GroupsUser.where(group_id: original_group_id, user_id: invited_user_id).first
      GroupsUser.update(group_user_mapping.id, group_id: new_group_id)
    else
      GroupsUser.create(group_id: new_group_id, user_id: invited_user_id)
    end
  end

  # This method handles all that needs to be done upon a user accepting an invite.
  # First the users previous group is deleted if they were the only member of that
  # group and topics that the old group signed up for will be deleted.
  # Then invites the user that accepted the invite sent will be removed.
  # Last the users group entry will be added to the TeamsUser table and their assigned topic is updated
  def self.accept_invite(group_id, inviter_user_id, invited_user_id, assignment_id)
    # if you are on a group and you accept another invitation and if your old group does not have any members, delete the entry for the group
    if GroupsUser.is_group_empty(group_id) and group_id != '0'
      assignment_id = Group.find(group_id).assignment.id
      # Release topics for the group has selected by the invited users empty group

      Group.remove_group_by_id(group_id)
    end

    # If you change your group, remove all your invitations that you send to other people
    Invitation.remove_users_sent_invites_for_assignment(invited_user_id, assignment_id)

    # Create a new group_user entry for the accepted invitation
    @group_user = GroupsUser.new
    can_add_member = GroupsUser.add_member_to_invited_group(inviter_user_id, invited_user_id, assignment_id)

    if can_add_member # The member was successfully added to the group (the group was not full)
      GroupInvitation.update_users_topic_after_invite_accept(inviter_user_id, invited_user_id, assignment_id)

      invited_participant = Participant.where(user_id: invited_user_id, parent_id: assignment_id).first
      inviter_participant = Participant.where(user_id: inviter_user_id, parent_id: assignment_id).first
      inviter_assignment_group = Group.group(inviter_participant)
    end

    can_add_member
  end

  def self.is_invited?(invitee_user_id, invited_user_id, assignment_id)
    sent_invitation = GroupInvitation.where(['from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"', invitee_user_id, invited_user_id, assignment_id])
    return true if sent_invitation.empty?
    false
  end

end
