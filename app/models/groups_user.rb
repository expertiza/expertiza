class GroupsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_one :group_user_node, foreign_key: :node_object_id, dependent: :destroy
  has_paper_trail
  attr_accessible :user_id, :group_id

  def name
    self.user.name
  end

  def delete
    GroupUserNode.find_by_node_object_id(self.id).destroy
    group = self.group
    self.destroy
    group.delete if group.groups_users.empty?
  end

  def get_group_members(group_id)
  end

  # Removes entry in the GroupUsers table for the given user and given group id
  def self.remove_group(user_id, group_id)
    group_user = GroupsUser.where(['user_id = ? and group_id = ?', user_id, group_id]).first
    group_user.destroy unless group_user.nil?
  end

  # Returns the first entry in the GroupUsers table for a given group id
  def self.first_by_group_id(group_id)
    GroupsUser.where("group_id = ?", group_id).first
  end

  # Determines whether a group is empty of not
  def self.is_group_empty(group_id)
    group_members = GroupsUser.where("group_id = ?", group_id)
    group_members.nil? || group_members.empty?
  end

  # Add member to the group they were invited to and accepted the invite for
  def self.add_member_to_invited_group(invitee_user_id, invited_user_id, assignment_id)
    users_groups = GroupsUser.where(['user_id = ?', invitee_user_id])
    for group in users_groups
      new_group = Group.where(['id = ? and parent_id = ?', group.group_id, assignment_id]).first
      unless new_group.nil?
        can_add_member = new_group.add_member(User.find(invited_user_id), assignment_id)
      end
    end
    can_add_member
  end

  # 2015-5-27 [zhewei]:
  # We just remove the topic_id field from the participants table.
  def self.group_id(assignment_id, user_id)
    # group_id variable represents the group_id for this user in this assignment
    group_id = nil
    groups_users = GroupsUser.where(user_id: user_id)
    groups_users.each do |groups_user|
      group = Group.find(groups_user.group_id)
      if group.parent_id == assignment_id
        group_id = groups_user.group_id
        break
      end
    end
    group_id
  end
end
