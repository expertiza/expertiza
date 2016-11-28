class Group < ActiveRecord::Base
  has_many :groups_users, dependent: :destroy
  has_many :users, through: :groups_users
  has_many :join_group_requests
  has_one :group_node, foreign_key: :node_object_id, dependent: :destroy

  # Get the participants of the given group
  def participants
    users.where(parent_id: parent_id || current_user_id).flat_map(&:participants)
  end
  alias get_participants participants

  # Get the response review map
  def responses
    participants.flat_map(&:responses)
  end

  # Delete the given group
  def delete
    for groupsuser in GroupsUser.where(["group_id =?", self.id])
      groupsuser.delete
    end
    node = GroupNode.find_by_node_object_id(self.id)
    node.destroy if node
    self.destroy
  end

  def get_node_type
    "GroupNode"
  end
  # Get the names of the users
  def get_reviewer_names
    names = []
    users.each do |user|
      names << user.fullname
    end
    names
  end

  # Check if the user exist
  def has_user(user)
    users.include? user
  end

  # Check if the current group is full?
  def full?
    return false if self.parent_id == nil #course group, does not group_size
    if Assignment.find(self.parent_id).group_size.nil?
      max_group_members = 5
    else
      max_group_members = Assignment.find(self.parent_id).group_size
    end
    curr_group_size = Group.size(self.id)
    (curr_group_size >= max_group_members)
  end
  
  # Add memeber to the group
  def add_member(user, _assignment_id)
    if has_user(user)
      raise "The user \"" + user.name + "\" is already a member of the group, \"" + self.name + "\""
    end

    if can_add_member = !full?
      t_user = GroupsUser.create(user_id: user.id, group_id: self.id)
      parent = GroupNode.find_by_node_object_id(self.id)
      GroupUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
      add_participant(self.parent_id, user)
    end

    can_add_member
  end

  # Add Participants to the current Assignment Group
  def add_participant(assignment_id, user)
    AssignmentParticipant.create(parent_id: assignment_id, user_id: user.id, permission_granted: user.master_permission_granted) if AssignmentParticipant.where(parent_id: assignment_id, user_id: user.id).first.nil?
  end

  # Define the size of the group
  def self.size(group_id)
    GroupsUser.where(["group_id = ?", group_id]).count
  end

  # Copy method to copy this group
  def copy_members(new_group)
    members = GroupsUser.where(group_id: self.id)
    members.each do |member|
      t_user = GroupsUser.create(group_id: new_group.id, user_id: member.user_id)
      parent = Object.const_get(self.parent_model).find(self.parent_id)
      GroupUserNode.create(parent_id: parent.id, node_object_id: t_user.id)
    end
  end

  # Algorithm
  # Start by adding single members to groups that are one member too small.
  # Add two-member groups to groups that two members too small. etc.
  def self.randomize_all_by_parent(parent, min_group_size)
    participants = Participant.where("parent_id = ?", parent.id)
    participants = participants.sort { rand(3) - 1 }
    users = participants.map {|p| User.find(p.user_id) }.to_a
    # find groups still need group members and users who are not in any group
    groups = Group.where(parent_id: parent.id).to_a
    groups_num = groups.size
    i = 0
    groups_num.times do
      groups_users = GroupsUser.where(group_id: groups[i].id)
      groups_users.each do |groups_user|
        users.delete(User.find(groups_user.user_id))
      end
      if Group.size(groups.first.id) >= min_group_size
        groups.delete(groups.first)
      else
        i += 1
      end
    end
    # sort groups by decreasing group size
    groups.sort_by {|group| Group.size(group.id) }.reverse!
    # insert users who are not in any group to groups still need group members
    if !users.empty? and !groups.empty?
      groups.each do |group|
        curr_group_size = Group.size(group.id)
        member_num_difference = min_group_size - curr_group_size
        for i in (1..member_num_difference).to_a
          group.add_member(users.first, parent.id)
          users.delete(users.first)
          break if users.empty?
        end
        break if users.empty?
      end
    end
    # If all the existing groups are fill to the min_group_size and we still have more users, create groups for them.
    if !users.empty?
      num_of_groups = users.length.fdiv(min_group_size).ceil
      nextGroupMemberIndex = 0
      for i in (1..num_of_groups).to_a
        group = Object.const_get('Group').create(name: "Group" + i.to_s, parent_id: parent.id)
        GroupNode.create(parent_id: parent.id, node_object_id: group.id)
        min_group_size.times do
          break if nextGroupMemberIndex >= users.length
          user = users[nextGroupMemberIndex]
          group.add_member(user, parent.id)
          nextGroupMemberIndex += 1
        end
      end
    end
  end

  # Generate the group name
  def self.generate_group_name(groupnameprefix)
    counter = 1
    while true
      groupname = groupnameprefix + "_Group#{counter}"
      return groupname if !Group.find_by_name(groupname)
      counter += 1
    end
  end

  # Extract group members from the csv and push to DB
  def import_group_members(starting_index, row)
    index = starting_index
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)
      if user.nil?
        raise ImportError, "The user \"" + row[index].to_s.strip + "\" was not found. <a href='/users/new'>Create</a> this user?"
      else
        if GroupsUser.where(["group_id =? and user_id =?", id, user.id]).first.nil?
          add_member(user, nil)
        end
      end
      index += 1
    end
  end


end