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
  #array of the average volume in each round of reviews
  attr_accessor :avg_vol_per_round
  attr_accessor :overall_avg_vol

  def dir_path
    assignment.try :directory_path
  end

  # all the participants in this assignment who have reviewed the team where this participant belongs
  def reviewers
    reviewers = []
    rmaps = ReviewResponseMap.where('reviewee_id = ?', self.team.id)
    rmaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end
    reviewers
  end

  # def review_score
  #   review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire" }[0]
  #   assessment = review_questionnaire.get_assessments_for(self)
  #   (Answer.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f
  # end

  # # Return scores that this participant has been given
  # # methods extracted from scores method: merge_scores, topic_total_scores, calculate_scores
  # def scores(questions)
  #   scores = {}
  #   scores[:participant] = self
  #   compute_assignment_score(questions, scores)
  #   scores[:total_score] = self.assignment.compute_total_score(scores)
  #   # merge scores[review#] (for each round) to score[review]  -Yang
  #   merge_scores(scores) if self.assignment.vary_by_round
  #   # In the event that this is a microtask, we need to scale the score accordingly and record the total possible points
  #   # PS: I don't like the fact that we are doing this here but it is difficult to make it work anywhere else
  #   topic_total_scores(scores) if self.assignment.microtask?

  #   # for all quiz questionnaires (quizzes) taken by the participant
  #   # quiz_responses = []
  #   # quiz_response_mappings = QuizResponseMap.where(reviewer_id: self.id)
  #   # quiz_response_mappings.each do |qmapping|
  #   #   quiz_responses << qmapping.response if qmapping.response
  #   # end
  #   # scores[:quiz] = Hash.new
  #   # scores[:quiz][:assessments] = quiz_responses
  #   # scores[:quiz][:scores] = Answer.compute_quiz_scores(scores[:quiz][:assessments])
  #   scores[:total_score] = assignment.compute_total_score(scores) if !self.assignment.vary_by_round
  #   # scores[:total_score] += compute_quiz_scores(scores)
  #   # move lots of calculation from view(_participant.html.erb) to model
  #   calculate_scores(scores)
  # end

  # def compute_assignment_score(questions, scores)
  #   counter_for_same_rubric = 0
  #   self.assignment.questionnaires.each do |questionnaire|
  #     if self.assignment.vary_by_round? && questionnaire.type == "ReviewQuestionnaire"
  #       questionnaires = AssignmentQuestionnaire.where(assignment_id: self.assignment.id, questionnaire_id: questionnaire.id)
  #       if questionnaires.count > 1
  #         round = questionnaires[counter_for_same_rubric].used_in_round
  #         counter_for_same_rubric += 1
  #       else
  #         round = questionnaires[0].used_in_round
  #         counter_for_same_rubric = 0
  #       end
  #     else
  #       round = AssignmentQuestionnaire.find_by(assignment_id: self.assignment.id, questionnaire_id: questionnaire.id).used_in_round
  #     end
  #     # create symbol for "varying rubrics" feature -Yang
  #     questionnaire_symbol = if round.nil?
  #                              questionnaire.symbol
  #                            else
  #                              (questionnaire.symbol.to_s + round.to_s).to_sym
  #                            end

  #     scores[questionnaire_symbol] = {}

  #     scores[questionnaire_symbol][:assessments] = if round.nil?
  #                                                    questionnaire.get_assessments_for(self)
  #                                                  else
  #                                                    questionnaire.get_assessments_round_for(self, round)
  #                                                  end
  #     scores[questionnaire_symbol][:scores] = Answer.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
  #   end
  # end

  # E1973, dummy method to match the functionality of AssignmentTeam
  def set_current_user(current_user)
  end

  # Copy this participant to a course
  def copy_to_course(course_id)
    CourseParticipant.find_or_create_by(user_id: self.user_id, parent_id: course_id)
  end

  def feedback
    FeedbackResponseMap.assessments_for(self)
  end

  def reviews
    # ACS Always get assessments for a team
    # removed check to see if it is a team assignment
    ReviewResponseMap.assessments_for(self.team)
  end

  # returns the reviewer of the assignment. Checks the reviewer_is_team flag to
  # determine whether this AssignmentParticipant or their team is the reviewer
  def get_reviewer
    return self.team if self.assignment.reviewer_is_team
    self
  end

  # polymorphic twin of method in AssignmentTeam
  # this method is called to check if the current user is this one
  def get_logged_in_reviewer_id(current_user_id)
    self.id
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
    files_list = Dir[directory + "/*"]
    files = []

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each {|f| files << f }
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
    raise ArgumentError, "No user id has been specified." if row_hash.empty?
    user = User.find_by(name: row_hash[:name])

    #if user with provided name in csv file is not present then new user will be created.
    if user.nil?
      raise ArgumentError, "The record containing #{row_hash[:name]} does not have enough items." if row_hash.length < 4

      #define_attributes method will return an element that stores values from the row_hash.
      attributes = ImportFileHelper.define_attributes(row_hash)

      #create_new_user method will create new user with values present in attribute.
      user = ImportFileHelper.create_new_user(attributes, session)

    end
    raise ImportError, "The assignment with id \"#{id}\" was not found." if Assignment.find(id).nil?

    #if user is already added to the assignment then return.
    return if AssignmentParticipant.exists?(user_id: user.id, parent_id: id)

    #if user is not already a participant then, user will be added to the assignment.
    new_part = AssignmentParticipant.create(user_id: user.id, parent_id: id)
    new_part.set_handle
  end

  # grant publishing rights to one or more assignments. Using the supplied private key,
  # digital signatures are generated.
  # reference: http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  def assign_copyright(private_key)
    # now, check to make sure the digital signature is valid, if not raise error
    self.permission_granted = self.verify_digital_signature(private_key)
    self.save
    raise 'Invalid key' unless self.permission_granted  
  end

  # verify the digital signature is valid
  def verify_digital_signature(private_key)
    user.public_key == OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
  end

  # define a handle for a new participant
  def set_handle
    self.handle = if self.user.handle.nil? or self.user.handle == ""
                    self.user.name
                  elsif AssignmentParticipant.exists?(parent_id: self.assignment.id, handle: self.user.handle)
                    self.user.name
                  else
                    self.user.handle
                  end
    self.save!
  end

  def path
    self.assignment.path + "/" + self.team.directory_num.to_s
  end

  # zhewei: this is the file path for reviewer to upload files during peer review
  def review_file_path(response_map_id)
    response_map = ResponseMap.find(response_map_id)
    first_user_id = TeamsUser.find_by(team_id: response_map.reviewee_id).user_id
    participant = Participant.find_by(parent_id: response_map.reviewed_object_id, user_id: first_user_id)
    self.assignment.path + "/" + participant.team.directory_num.to_s + "_review" + "/" + response_map_id.to_s
  end

  def current_stage
    topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
    assignment.try :current_stage, topic_id
  end

  def stage_deadline
    topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
    stage = assignment.stage_deadline(topic_id)
    if stage == 'Finished'
      return (assignment.staggered_deadline? ? TopicDueDate.find_by(parent_id: topic_id).try(:last).try(:due_at) : assignment.due_dates.last.due_at).to_s
    end
    stage
  end
end