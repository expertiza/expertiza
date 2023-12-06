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

    user = User.find_by(name: row_hash[:name])

    # if user with provided name in csv file is not present then new user will be created.
    if user.nil?
      raise ArgumentError, "The record containing #{row_hash[:name]} does not have enough items." if row_hash.length < 4

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

  def team_user
    TeamsUser.where(team_id: team.id, user_id: user_id).first if team
  end
end
