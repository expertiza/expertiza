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
  has_many    :quiz_mappings, class_name: 'QuizResponseMap', foreign_key: 'reviewee_id'
  has_many :response_maps, foreign_key: 'reviewee_id'
  has_many :participant_review_response_maps, foreign_key: 'reviewee_id'
  has_many :quiz_response_maps, foreign_key: 'reviewee_id'
  has_many :quiz_responses, through: :quiz_response_maps, foreign_key: 'map_id'
  # has_many    :quiz_responses,  :class_name => 'Response', :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'QuizResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  # has_many    :responses, :finder_sql => 'SELECT r.* FROM responses r, response_maps m, participants p WHERE r.map_id = m.id AND m.type = \'ReviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  belongs_to :user
  validates_presence_of :handle
  attr_accessor :overall_avg_vol
  attr_accessor :avg_vol_in_round_1
  attr_accessor :avg_vol_in_round_2
  attr_accessor :avg_vol_in_round_3
 
  # Returns the average score of one question from all reviews for this user on this assignment as an floating point number
  # Params: question - The Question object to retrieve the scores from
  def average_question_score(question)
    sum_of_scores = 0
    number_of_scores = 0

    self.response_maps.each do |response_map|
      # TODO: There must be a more elegant way of doing this...
      next if response_map.response.empty?
      response_map.response.last.scores.each do |score|
        if score.question == question
          sum_of_scores += score.score
          number_of_scores += 1
        end
      end
    end

    return 0 if number_of_scores == 0
    ((sum_of_scores.to_f / number_of_scores.to_f) * 100).to_i / 100.0
  end

  def dir_path
    assignment.try :directory_path
  end

  # Returns the average score of all reviews for this user on this assignment
  def average_score
    return 0 if self.response_maps.empty?

    sum_of_scores = 0

    self.response_maps.each do |response_map|
      unless response_map.response.empty?
        sum_of_scores += response_map.response.last.average_score
      end
    end

    (sum_of_scores / self.response_maps.size).to_i
  end

  def assign_quiz(contributor, reviewer, _topic)
    # using topic_id to find first participant.id.
    teams = SignedUpTeam.where(topic_id: @topic_id)
    teams.each do |team|
      users = TeamsUser.where(team_id: team.id)
      participant_id = Participant.where(user_id: users.first.id, parent_id: @assignment_id).id
      break
    end
    quiz = QuizQuestionnaire.find_by_instructor_id(contributor.id)
    QuizResponseMap.create(reviewed_object_id: quiz.id, reviewee_id: contributor.id, reviewer_id: reviewer.id,
                           type: "QuizResponseMap")
  end

  def self.find_by_user_id_and_assignment_id(user_id, assignment_id)
    AssignmentParticipant.where(user_id: user_id, parent_id: assignment_id).first
  end

  # all the participants in this assignment who have reviewed this person
  def reviewers
    reviewers = []
    rmaps = ResponseMap.where(["reviewee_id = #{self.team.id} AND type = 'ReviewResponseMap'"])
    rmaps.each do |rm|
      reviewers.push(AssignmentParticipant.find(rm.reviewer_id))
    end

    reviewers
  end

  def review_score
    review_questionnaire = self.assignment.questionnaires.select {|q| q.type == "ReviewQuestionnaire" }[0]
    assessment = review_questionnaire.get_assessments_for(self)
    (Answer.compute_scores(assessment, review_questionnaire.questions)[:avg] / 100.00) * review_questionnaire.max_possible_score.to_f
  end

  def fullname
    self.user.fullname
  end

  def name
    self.user.name
  end

  # Return scores that this participant has been given
  def scores(questions)
    scores = {}
    scores[:participant] = self
    self.assignment.questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.assignment.id, questionnaire.id).used_in_round
      # create symbol for "varying rubrics" feature -Yang
      questionnaire_symbol = if round.nil?
                               questionnaire.symbol
                             else
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             end

      scores[questionnaire_symbol] = {}

      scores[questionnaire_symbol][:assessments] = if round.nil?
                                                     questionnaire.get_assessments_for(self)
                                                   else
                                                     questionnaire.get_assessments_round_for(self, round)
                                                   end
      scores[questionnaire_symbol][:scores] = Answer.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
    end

    scores[:total_score] = self.assignment.compute_total_score(scores)

    # merge scores[review#] (for each round) to score[review]  -Yang
    if self.assignment.varying_rubrics_by_round?
      review_sym = "review".to_sym
      scores[review_sym] = {}
      scores[review_sym][:assessments] = []
      scores[review_sym][:scores] = {}
      scores[review_sym][:scores][:max] = -999_999_999
      scores[review_sym][:scores][:min] = 999_999_999
      scores[review_sym][:scores][:avg] = 0
      total_score = 0
      for i in 1..self.assignment.num_review_rounds
        round_sym = ("review" + i.to_s).to_sym
        if scores[round_sym].nil? || scores[round_sym][:assessments].nil? || scores[round_sym][:assessments].empty?
          next
        end
        length_of_assessments = scores[round_sym][:assessments].length.to_f

        scores[review_sym][:assessments] += scores[round_sym][:assessments]

        if !scores[round_sym][:scores][:max].nil? && scores[review_sym][:scores][:max] < scores[round_sym][:scores][:max]
          scores[review_sym][:scores][:max] = scores[round_sym][:scores][:max]
        end
        if !scores[round_sym][:scores][:min].nil? && scores[review_sym][:scores][:min] > scores[round_sym][:scores][:min]
          scores[review_sym][:scores][:min] = scores[round_sym][:scores][:min]
        end
        unless scores[round_sym][:scores][:avg].nil?
          total_score += scores[round_sym][:scores][:avg] * length_of_assessments
        end
      end

      if scores[review_sym][:scores][:max] == -999_999_999 && scores[review_sym][:scores][:min] == 999_999_999
        scores[review_sym][:scores][:max] = 0
        scores[review_sym][:scores][:min] = 0
      end

      scores[review_sym][:scores][:avg] = total_score / scores[review_sym][:assessments].length.to_f
    end

    # In the event that this is a microtask, we need to scale the score accordingly and record the total possible points
    # PS: I don't like the fact that we are doing this here but it is difficult to make it work anywhere else
    if assignment.is_microtask?
      topic = SignUpTopic.find_by_assignment_id(assignment.id)
      unless topic.nil?
        scores[:total_score] *= (topic.micropayment.to_f / 100.to_f)
        scores[:max_pts_available] = topic.micropayment
      end
    end

    # for all quiz questionnaires (quizzes) taken by the participant
    quiz_responses = []
    quiz_response_mappings = QuizResponseMap.where(reviewer_id: self.id)
    quiz_response_mappings.each do |qmapping|
      quiz_responses << qmapping.response if qmapping.response
    end
    # scores[:quiz] = Hash.new
    # scores[:quiz][:assessments] = quiz_responses
    # scores[:quiz][:scores] = Answer.compute_quiz_scores(scores[:quiz][:assessments])

    scores[:total_score] = assignment.compute_total_score(scores)
    # scores[:total_score] += compute_quiz_scores(scores)

    # move lots of calculation from view(_participant.html.erb) to model
    if self.grade
      scores[:total_score] = self.grade
    else
      total_score = scores[:total_score]
      total_score = 100 if total_score > 100
      scores[:total_score] = total_score
      scores
    end
  end

  # Copy this participant to a course
  def copy(course_id)
    part = CourseParticipant.where(user_id: self.user_id, parent_id: course_id).first
    CourseParticipant.create(user_id: self.user_id, parent_id: course_id) if part.nil?
  end

  def feedback
    FeedbackResponseMap.get_assessments_for(self)
  end

  def reviews
    # ACS Always get assessments for a team
    # removed check to see if it is a team assignment
    ReviewResponseMap.get_assessments_for(self.team)
  end

  def reviews_by_reviewer(reviewer)
    ReviewResponseMap.get_reviewer_assessments_for(self.team, reviewer)
  end

  def quizzes_taken
    QuizResponseMap.get_assessments_for(self)
  end

  def metareviews
    MetareviewResponseMap.get_assessments_for(self)
  end

  def teammate_reviews
    TeammateReviewResponseMap.get_assessments_for(self)
  end

  def bookmark_reviews
    BookmarkRatingResponseMap.get_assessments_for(self)
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
  def self.import(row, _row_header = nil, session, id)
    raise ArgumentError, "No user id has been specified." if row.empty?
    user = User.find_by_name(row[0])
    if user.nil?
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
    raise ImportError, "The assignment with id \"" + id.to_s + "\" was not found." if Assignment.find(id).nil?
    unless AssignmentParticipant.exists?(user_id: user.id, parent_id: id)
      new_part = AssignmentParticipant.create(user_id: user.id, parent_id: id)
      new_part.set_handle
    end
  end

  # provide export functionality for Assignment Participants
  def self.export(csv, parent_id, _options)
    where(parent_id: parent_id).find_each do |part|
      user = part.user
      csv << [
        user.name,
        user.fullname,
        user.email,
        user.role.name,
        user.parent.name,
        user.email_on_submission,
        user.email_on_review,
        user.email_on_review_of_review,
        part.handle
      ]
    end
  end

  def self.export_fields(_options)
    ["name", "full name", "email", "role", "parent", "email on submission", "email on review", "email on metareview", "handle"]
  end

  # grant publishing rights to one or more assignments. Using the supplied private key,
  # digital signatures are generated.
  # reference: http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/
  def self.grant_publishing_rights(private_key, participants)
    participants.each do |participant|
      # now, check to make sure the digital signature is valid, if not raise error
      participant.permission_granted = participant.verify_digital_signature(private_key)
      participant.save
      raise 'Invalid key' unless participant.permission_granted
    end
  end

  # verify the digital signature is valid
  def verify_digital_signature(private_key)
    user.public_key == OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
  end

  # define a handle for a new participant
  def set_handle
    self.handle = if self.user.handle.nil? or self.user.handle == ""
                    self.user.name
                  elsif !AssignmentParticipant.where(parent_id: self.assignment.id, handle: self.user.handle).empty?
                    self.user.name
                  else
                    self.user.handle
                  end
    self.save!
  end

  def path
    self.assignment.path + "/" + self.team.directory_num.to_s
  end

  # zhewei: this is the file path for reviewer uploaded files during peer review
  def review_file_path(response_map_id)
    response_map = ResponseMap.find(response_map_id)
    first_user_id = TeamsUser.where(team_id: response_map.reviewee_id).first.user_id
    participant = Participant.where(parent_id: response_map.reviewed_object_id, user_id: first_user_id).first
    self.assignment.path + "/" + participant.team.directory_num.to_s + "_review" + "/" + response_map_id.to_s
  end

  def update_resubmit_times
    new_submit = ResubmissionTime.new(resubmitted_at: Time.now.to_s)
    self.resubmission_times << new_submit
  end

  def current_stage
    topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
    assignment.try :get_current_stage, topic_id
  end

  def stage_deadline
    topic_id = SignedUpTeam.topic_id(self.parent_id, self.user_id)
    assignment.stage_deadline topic_id
  end

  def review_response_maps
    participant = Participant.find(id)
    team_id = TeamsUser.team_id(participant.parent_id, participant.user_id)
    ReviewResponseMap.where(reviewee_id: team_id, reviewed_object_id: assignment.id)
  end
end
