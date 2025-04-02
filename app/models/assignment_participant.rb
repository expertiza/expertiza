require 'uri'
require 'yaml'
# Code Review: Notice that Participant overloads two different concepts:
#              contribution and participant (see fields of the participant table).
#              Consider creating a new table called contributions.
#
# Alias methods exist in this class which append 'get_' to many method names. Use
# the idiomatic ruby method names (without get_)

class AssignmentParticipant < Participant
  belongs_to  :assignment, class_name: 'Assignment', foreign_key: 'parent_id'
  has_many    :review_mappings, class_name: 'ReviewResponseMap', foreign_key: 'reviewee_id'
  has_many    :response_maps, foreign_key: 'reviewee_id'
  has_many    :quiz_mappings, class_name: 'QuizResponseMap', foreign_key: 'reviewee_id'
  has_many :quiz_response_maps, foreign_key: 'reviewee_id'
  has_many :quiz_responses, through: :quiz_response_maps, foreign_key: 'map_id'
  # has_many    :quiz_responses,  :class_name => 'Response', :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'QuizResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  # has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'ReviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  belongs_to :user
  validates :handle, presence: true
  # array of the average volume in each round of reviews
  attr_accessor :avg_vol_per_round
  attr_accessor :overall_avg_vol

  # Nested class to encapsulate selection parameters
  class SelectionParams
    attr_reader :team, :iterator, :participants, :participants_hash, :assignment_id, :review_strategy

    def initialize(team:, iterator:, participants:, participants_hash:, assignment_id:, review_strategy:)
      @team = team
      @iterator = iterator
      @participants = participants
      @participants_hash = participants_hash
      @assignment_id = assignment_id
      @review_strategy = review_strategy
    end
  end

  def dir_path
    assignment.try :directory_path
  end

  # all the participants in this assignment who have reviewed the team where this participant belongs
  def reviewers
    reviewers = []
    rmaps = ReviewResponseMap.where('reviewee_id = ?', team.id)
    rmaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end
    reviewers
  end

  # E1973, dummy method to match the functionality of AssignmentTeam
  def set_current_user(current_user); end

  # Copy this participant to a course
  def copy_to_course(course_id)
    CourseParticipant.find_or_create_by(user_id: user_id, parent_id: course_id)
  end

  def feedback
    FeedbackResponseMap.assessments_for(self)
  end

  def reviews
    # ACS Always get assessments for a team
    # removed check to see if it is a team assignment
    ReviewResponseMap.assessments_for(team)
  end

  # returns the reviewer of the assignment. Checks the team_reviewing_enabled flag to
  # determine whether this AssignmentParticipant or their team is the reviewer
  def get_reviewer
    return team if assignment.team_reviewing_enabled

    self
  end

  # polymorphic twin of method in AssignmentTeam
  # this method is called to check if the current user is this one
  def get_logged_in_reviewer_id(_current_user_id)
    id
  end

  # checks if this assignment participant is the currently logged on user, given their user id
  def current_user_is_reviewer?(current_user_id)
    user_id == current_user_id
  end

  def quizzes_taken
    QuizResponseMap.assessments_for(self)
  end

  def metareviews
    MetareviewResponseMap.assessments_for(self)
  end

  def teammate_reviews
    TeammateReviewResponseMap.assessments_for(self)
  end

  def bookmark_reviews
    BookmarkRatingResponseMap.assessments_for(self)
  end

  def files(directory)
    files_list = Dir[directory + '/*']
    files = []

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each { |f| files << f }
      end
      files << file
    end
    files
  end

  def team
    AssignmentTeam.team(self)
  end

  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment

  def self.import(row_hash, _row_header = nil, session, id)
    raise ArgumentError, 'No user id has been specified.' if row_hash.empty?

    user = User.find_by(name: row_hash[:username])

    # if user with provided name in csv file is not present then new user will be created.
    if user.nil?
      raise ArgumentError, "The record containing #{row_hash[:username]} does not have enough items." if row_hash.length < 4

      # define_attributes method will return an element that stores values from the row_hash.
      attributes = ImportFileHelper.define_attributes(row_hash)

      # create_new_user method will create new user with values present in attribute.
      user = ImportFileHelper.create_new_user(attributes, session)

    end
    raise ImportError, "The assignment with id \"#{id}\" was not found." if Assignment.find(id).nil?

    # if user is already added to the assignment then return.
    return if AssignmentParticipant.exists?(user_id: user.id, parent_id: id)

    # if user is not already a participant then, user will be added to the assignment.
    new_part = AssignmentParticipant.create(user_id: user.id, parent_id: id)
    new_part.set_handle
  end

  # grant publishing rights to one or more assignments. Using the supplied private key,
  # digital signatures are generated.
  # reference: http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  def assign_copyright(private_key)
    # now, check to make sure the digital signature is valid, if not raise error
    self.permission_granted = verify_digital_signature(private_key)
    save
    raise 'Invalid key' unless permission_granted
  end

  # verify the digital signature is valid
  def verify_digital_signature(private_key)
    user.public_key == OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
  end

  # define a handle for a new participant
  def set_handle
    self.handle = if user.handle.nil? || (user.handle == '')
                    user.name
                  elsif AssignmentParticipant.exists?(parent_id: assignment.id, handle: user.handle)
                    user.name
                  else
                    user.handle
                  end
    save!
  end

  def path
    assignment.path + '/' + team.directory_num.to_s
  end

  # zhewei: this is the file path for reviewer to upload files during peer review
  def review_file_path(response_map_id = nil, participant = nil)
    if response_map_id.nil?
      return if participant.nil?

      no_team_path = assignment.path + '/' + participant.name.parameterize(separator: '_') + '_review'
      return no_team_path if participant.team.nil?
    end

    response_map = ResponseMap.find(response_map_id)
    first_user_id = TeamsUser.find_by(team_id: response_map.reviewee_id).user_id
    participant = Participant.find_by(parent_id: response_map.reviewed_object_id, user_id: first_user_id)
    return if participant.nil?

    assignment.path + '/' + participant.team.directory_num.to_s + '_review' + '/' + response_map_id.to_s
  end

  def current_stage
    topic_id = SignedUpTeam.topic_id(parent_id, user_id)
    assignment.try :current_stage, topic_id
  end

  def stage_deadline
    topic_id = SignedUpTeam.topic_id(parent_id, user_id)
    stage = assignment.stage_deadline(topic_id)
    if stage == 'Finished'
      return (assignment.staggered_deadline? ? TopicDueDate.find_by(parent_id: topic_id).try(:last).try(:due_at) : assignment.due_dates.last.due_at).to_s
    end

    stage
  end

  # E2147 : Gets duty id of the assignment participant by mapping teams user with help of
  # user_id. Will no longer be needed once teams_user is converted into participant_teams
  def duty_id
    participant = team_user
    return participant.duty_id if participant
  end

  # Determines if the participant has exceeded the maximum number of outstanding (incomplete) reviews
  
  def below_outstanding_reviews_limit?(assignment)
    total_reviews = ReviewResponseMap.where(
      reviewer_id: id,
      reviewed_object_id: assignment.id
    ).count
  
    return true if total_reviews.zero?
  
    completed_reviews = Response.joins(:response_map)
                                .where(response_maps: { reviewer_id: id, reviewed_object_id: assignment.id })
                                .where(is_submitted: true)
                                .select("DISTINCT response_maps.id")
                                .count
  
    (total_reviews - completed_reviews) < Assignment.max_outstanding_reviews
  end

  def team_user
    TeamsUser.where(team_id: team.id, user_id: user_id).first if team
  end

  # Returns an array of participant IDs who need more reviews
  def self.participants_needing_reviews(participants_hash, review_strategy)
    participants_hash.select { |_, review_num| review_num < review_strategy.reviews_per_student }
                    .keys
  end

  # Returns true if the participant is a member of the given team
  def in_team?(team_id)
    TeamsUser.exists?(team_id: team_id, user_id: user_id)
  end

  # Returns an array of participant indices who have minimum reviews
  def self.participants_with_min_reviews(participants, participants_hash)
    min_value = participants_hash.values.min
    participants.each_with_index.select { |participant, _| participants_hash[participant.id] == min_value }
                .map(&:last)
  end

  # Returns a random participant index based on strategy
  def self.select_random_participant(iterator, participants, participants_hash, team_id)
    if iterator.zero?
      rand(0..participants.size - 1)
    else
      select_participant_by_min_reviews(participants, participants_hash, team_id)
    end
  end

  # Selects participants for a team based on review strategy
  def self.select_participants_for_team(team, iterator, participants, participants_hash, assignment_id, review_strategy)
    params = SelectionParams.new(
      team: team,
      iterator: iterator,
      participants: participants,
      participants_hash: participants_hash,
      assignment_id: assignment_id,
      review_strategy: review_strategy
    )
    if team.equal? team.class.last
      select_participants_for_last_team(params)
    else
      select_participants_for_regular_team(params)
    end
  end

  # Selects participants for a regular team
  def self.select_participants_for_regular_team(params)
    selected_participants = []
    valid_participants_count = ReviewResponseMap.valid_team_participants_count(params.team.id, params.assignment_id)
    while selected_participants.size < params.review_strategy.reviews_per_team
      break if selected_participants.size == params.participants.size - valid_participants_count
      participant_index = select_random_participant(params.iterator, params.participants, params.participants_hash, params.team.id)
      next unless can_select_participant?(participant_index, params, selected_participants)
      selected_participants << params.participants[participant_index].id
      params.participants_hash[params.participants[participant_index].id] += 1
      remove_completed_participants(params.participants, params.participants_hash, params.review_strategy, participant_index)
    end
    selected_participants
  end

  # Selects participants for the last team
  def self.select_participants_for_last_team(params)
    params.participants.select do |participant|
      if ReviewResponseMap.can_review_team?(participant.user_id, params.team.id) &&
        params.participants_hash[participant.id] < params.review_strategy.reviews_per_student
        params.participants_hash[participant.id] += 1
        true
      else
        false
      end
    end.map(&:id)
  end

  # Checks if a participant can be selected for review
  def self.can_select_participant?(participant_index, params, selected_participants)
    participant = params.participants[participant_index]
    return false unless ReviewResponseMap.can_review_team?(participant.user_id, params.team.id)
    return false if params.participants_hash[participant.id] >= params.review_strategy.reviews_per_student
    return false if selected_participants.include?(participant.id)
    true
  end

  # Removes participants who have completed their required reviews
  def self.remove_completed_participants(participants, participants_hash, review_strategy, participant_index)
    participants.each do |participant|
      if participants_hash[participant.id] == review_strategy.reviews_per_student
        participants.delete_at(participant_index)
      end
    end
  end

  def self.select_participant_by_min_reviews(participants, participants_hash, team_id)
    min_review_indices = participants_with_min_reviews(participants, participants_hash)
    if min_review_indices.empty? ||
       (min_review_indices.size == 1 && ReviewResponseMap.can_review_team?(participants[min_review_indices[0]].user_id, team_id))
      rand(0..participants.size - 1)
    else
      min_review_indices.sample
    end
  end
end
