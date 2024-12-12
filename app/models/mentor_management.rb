class MentorManagement
  # Select a mentor using the following algorithm
  #
  # 1) Find all assignment participants for the
  #    assignment with id [assignment_id] whose
  #    duty is the same as [Participant#DUTY_MENTOR].
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
    mentor_user_id, = zip_mentors_with_team_count(assignment_id).first
    User.where(id: mentor_user_id).first
  end

  # = Mentor Management
  # E2115: Handles calls when an assignment has the auto_assign_mentor flag enabled and triggered by the event when a new member joins an assignment team.
  #
  # This event happens when:
  #   1.) An invited student user accepts and successfully added to a team from
  #       app/models/invitation.rb
  #   2.) A student user is successfully added to the team manually from
  #       app/controllers/teams_users_controller.rb.
  #
  # This method will determine if a mentor needs to be assigned, if so,
  # selects one, and adds the mentor to the team if:
  #   1.) The assignment does not have a topic.
  #   2.) If the team has reached >50% full capacity.
  #   3.) If the team does not have a mentor.
  def self.assign_mentor(assignment_id, team_id)
    assignment = Assignment.find(assignment_id)
    team = Team.find(team_id)

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if assignments can't accept mentors
    return unless assignment.auto_assign_mentor

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if the assignment or team already have a topic
    return if assignment.topics? || !team.topic.nil?

    curr_team_size = Team.size(team_id)
    max_team_members = Assignment.find(assignment_id).max_team_size

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if the team size hasn't reached > 50% of capacity
    return if curr_team_size * 2 <= max_team_members

    # RuboCop 'use guard clause instead of nested conditionals'
    # return if there's already a mentor in place
    return if team.participants.any? { |participant| participant.can_mentor == true }

    mentor_user = select_mentor(assignment_id)

    # Add the mentor using team model class.
    team_member_added = mentor_user.nil? ? false : team.add_member(mentor_user, assignment_id)

    return unless team_member_added

    notify_team_of_mentor_assignment(mentor_user, team)
  end

  def self.notify_team_of_mentor_assignment(mentor, team)
    members = team.users
    emails = members.map(&:email)
    members_info = members.map { |mem| "#{mem.fullname} - #{mem.email}" }
    mentor_info = "#{mentor.fullname} (#{mentor.email})"
    message = "#{mentor_info} has been assigned as your mentor for assignment #{Assignment.find(team.parent_id).name} <br>Current members:<br> #{members_info.join('<br>')}"

    Mailer.delayed_message(bcc: emails,
                           subject: '[Expertiza]: New Mentor Assignment',
                           body: message).deliver_now
  end

  # Returns true if [user] is a mentor, and false if not.
  #
  # [user] must be a User object.
  #
  # Checks the Participant relation to see if a row exists with
  # user_id == user.id that also has 'mentor' in the duty attribute.
  def self.user_a_mentor?(user)
    Participant.exists?(user_id: user.id, can_mentor: true)
  end

  # Select all the participants who's duty in the participant
  # table is [DUTY_MENTOR], and who are a participant of
  # [assignment_id].
  #
  # @see participant.rb for the value of DUTY_MENTOR
  def self.mentors_for_assignment(assignment_id)
    Participant.where(parent_id: assignment_id, can_mentor: true)
  end

  # Produces a hash mapping mentor's user_ids to the aggregated
  # number of teams they're part of, which acts as a proxy for
  # the number of teams they're mentoring.
  def self.zip_mentors_with_team_count(assignment_id)
    mentor_ids = mentors_for_assignment(assignment_id).pluck(:user_id)

    return [] if mentor_ids.empty?

    team_counts = {}
    mentor_ids.each { |id| team_counts[id] = 0 }
    #E2351 removed (:team_id) after .count to fix balancing algorithm
    team_counts.update(TeamsUser.where(user_id: mentor_ids).group(:user_id).count)

    team_counts.sort_by { |_, v| v }
  end
end
