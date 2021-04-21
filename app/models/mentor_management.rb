class MentorManagement
  # Select a mentor using the following algorithm
  #
  # 1) Find all assignment participants for the
  #    assignment with id [assignment_id] whose
  #    duty is the same as [Particpant#DUTY_MENTOR].
  # 2) Count the number of teams those participants
  #    are a part of, acting as a proxy for the
  #    number of teams they mentor.
  # 3) Return the mentor with the fewest number of
  #    teams they're currently mentoring.
  #
  # This method's runtime is O(n lg n) due to the call to
  # Hash#sort_by. This assertion assumes that the
  # database management system is capable of fetching the
  # required rows at least as quickly.
  #
  # Implementation detail: Any tie between the top 2
  # mentors is decided by the Hash#sort_by algorithm.
  #
  # @return The id of the mentor with the fewest teams
  #   they are assigned to. Returns `nil` if there are
  #   no participants with mentor duty for [assignment_id].
  def self.select_mentor(assignment_id)
    mentor_user_id, _ = self.zip_mentors_with_team_count(assignment_id).first
    User.where(id: mentor_user_id).first
  end

  def self.update_mentor_state(assignment_id, team_id)
    assignment = Assignment.find(assignment_id)
    team = Team.find(team_id)

    return if assignment.topics? || !team.topic.nil?

    curr_team_size = Team.size(team_id)
    max_team_members = Assignment.find(assignment_id).max_team_size

    # RuboCop 'use guard clause instead of nested conditionals'
    return if curr_team_size * 2 <= max_team_members

    # RuboCop 'use guard clause instead of nested conditionals'
    return if team.participants.any? { |participant| participant.duty == Participant::DUTY_MENTOR }

    mentor_user = select_mentor(assignment_id)
    team.add_member(mentor_user, assignment_id=assignment_id) unless mentor_user.nil?
  end

  def self.user_a_mentor?(user)
    Participant.exists?(user_id: user.id, duty: Participant::DUTY_MENTOR)
  end

  # Select all the participants who's duty in the participant
  # table is [DUTY_MENTOR].
  #
  # @see participant.rb for the value of DUTY_MENTOR
  def self.get_all_mentors
    Participant.where(duty: Participant::DUTY_MENTOR)
  end

  # Select all the participants who's duty in the participant
  # table is [DUTY_MENTOR], and who are a participant of
  # [assignment_id].
  #
  # @see participant.rb for the value of DUTY_MENTOR
  def self.get_mentors_for_assignment(assignment_id)
    Participant.where(parent_id: assignment_id, duty: Participant::DUTY_MENTOR)
  end

  # Produces a hash mapping mentor's user_ids to the aggregated
  # number of teams they're part of, which acts as a proxy for
  # the number of teams they're mentoring.
  def self.zip_mentors_with_team_count(assignment_id)
    mentor_ids = self.get_mentors_for_assignment(assignment_id).pluck(:user_id)

    return {} if mentor_ids.empty?

    team_counts = {}
    mentor_ids.each { |id| team_counts[id] = 0 }
    team_counts.update(TeamsUser.where(user_id: mentor_ids).group(:user_id).count(:team_id))

    team_counts.sort_by { |_, v| v }
  end

end