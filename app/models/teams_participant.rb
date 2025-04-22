class TeamsParticipant < ApplicationRecord
  belongs_to :team
  belongs_to :participant

  # paper_trail, node, etc
  has_one    :team_participant_node,
             foreign_key: 'node_object_id',
             dependent:   :destroy
  has_paper_trail

  # delegate the underlying user and user_id
  delegate :user, :user_id, to: :participant

  # for the “Add” form
  attr_accessor :user_name

  # exactly the old .name/ip‑address logic
  def name(ip_address = nil)
    base = user.name(ip_address)
    base += ' (Mentor)' if MentorManagement.user_a_mentor?(user)
    base
  end

  # destroy your node, the join record, and delete the team if empty
  def delete
    team_participant_node&.destroy
    t = team
    destroy
    t.destroy if t.teams_participants.empty?
  end

  # remove all membership entries for a given user‑ID + team‑ID
  def self.remove_team(user_id, team_id)
    jp = joins(participant: :user)
           .where('participants.user_id = ? AND team_id = ?', user_id, team_id)
           .first
    jp&.destroy
  end

  # first participant record in a team
  def self.first_by_team_id(team_id)
    where(team_id: team_id).first
  end

  # is the team empty?
  def self.team_empty?(team_id)
    where(team_id: team_id).none?
  end

  # “inviter” invites “invited” into their team for an assignment
  def self.add_member_to_invited_team(invitee_user_id, invited_user_id, assignment_id)
    success = false
    each_for(invitee_user_id) do |tp|
      next unless (asg_team = AssignmentTeam.find_by(id: tp.team_id, parent_id: assignment_id))
      invited_participant = Participant.find_by(user_id: invited_user_id, parent_id: assignment_id)
      success = asg_team.add_member(invited_participant) if invited_participant
    end
    success
  end

  # helper for all‐teams‐for‐a‐user
  def self.each_for(user_id, &block)
    joins(participant: :user)
      .where('participants.user_id = ?', user_id)
      .each(&block)
  end

  # find the team_id for a given (assignment_id, user_id)
  def self.team_id(assignment_id, user_id)
    each_for(user_id).find { |tp| tp.team.parent_id == assignment_id }&.team_id
  end
end
