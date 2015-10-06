class Response < ActiveRecord::Base
  belongs_to :response_map, :class_name => 'ResponseMap', :foreign_key => 'map_id'
  has_many :scores, :class_name => 'Answer', :foreign_key => 'response_id', :dependent => :destroy
  has_many :metareview_response_maps, :class_name => 'MetareviewResponseMap', :foreign_key => 'reviewed_object_id', dependent: :destroy

  alias_method :map, :response_map

  attr_accessor :difficulty_rating

  delegate :questionnaire, :reviewee, :reviewer, :to => :map

  def response_id
    id
  end

  def team_has_user?(user)
    reviewer.team.has_user user
  end

  def display_as_html(prefix = nil, count = nil, file_url = nil)
    identifier = ""
    # The following three lines print out the type of rubric before displaying
    # feedback.  Currently this is only done if the rubric is Author Feedback.
    # It doesn't seem necessary to print out the rubric type in the case of
    # a ReviewResponseMap.  Also, I'm not sure if that would have to be
    # TeamResponseMap for a team assignment.  Someone who understands the
    # situation better could add to the code later.
    if self.map.type.to_s == 'FeedbackResponseMap'
      identifier += "<H2>Feedback from author</H2>"
    end
    if prefix
      identifier += "<B>Reviewer:</B> #{count}" #+self.map.reviewer.fullname
      str = prefix+"_"+self.id.to_s
    else
      identifier += '<B>'+self.map.get_title+'</B> '+count.to_s+'</B>'
      str = self.id.to_s
    end
    code = identifier+'&nbsp;&nbsp;&nbsp;<a href="#" name= "review_'+str+'Link" onClick="toggleElement('+"'review_"+str+"','review'"+');return false;">hide review</a><BR/>'
    code += "<B>Last reviewed:</B> "
    if self.updated_at.nil?
      code += "Not available"
    else
      code += self.updated_at.strftime('%A %B %d %Y, %I:%M%p')
    end
    code += '<div id="review_'+str+'" style=""><BR/><BR/>'

    count = 0
    answers = Answer.where(response_id: self.response_id)

    questionnaire = self.questionnaire_by_answer(answers.first)

    questionnaire_max = questionnaire.max_question_score
    questions=questionnaire.questions.sort { |a,b| a.seq <=> b.seq }
    #loop through questions so the the questions are displayed in order based on seq (sequence number)
    questions.each do |question|
      count += 1 if !question.is_a? QuestionnaireHeader and question.break_before == true
      answer = answers.find{|a| a.question_id==question.id}
      if !answer.nil? or question.is_a? QuestionnaireHeader
        if question.instance_of? Criterion or question.instance_of? Scale
          code += question.view_completed_question(count,answer,questionnaire_max)
        else
          code += question.view_completed_question(count,answer)
        end
      end
    end

    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p', '').gsub(/\n/, '<BR/>')
    else
      comment = ''
    end
    code += "<BR><BR><B>Additional Comment:</B><BR/>"+comment+"</div>"
    return code.html_safe
  end

  # Computes the total score awarded for a review
  def get_total_score
    # only count the scorable questions, only when the answer is not nil (we accept nil as answer for scorable questions, and they will not be counted towards the total score)
    sum=0
    scores.each do |s|
      question = Question.find(s.question_id)
      if !s.answer.nil? && question.is_a?(ScoredQuestion)
        sum += s.answer*question.weight
      end
    end
    sum
  end

  def delete
    self.scores.each { |score| score.destroy }
    self.destroy
  end

  #bug fixed
  # Returns the average score for this response as an integer (0-100)
  def get_average_score()
    if get_maximum_score != 0 then
      ((get_total_score.to_f / get_maximum_score.to_f) * 100).round
    else
      "N/A"
    end
  end

  # Returns the maximum possible score for this response
  def get_maximum_score()
    # only count the scorable questions, only when the answer is not nil (we accept nil as answer for scorable questions, and they will not be counted towards the total score)
    total_weight = 0
    scores.each do |s|
      question = Question.find(s.question_id)
      if !s.answer.nil? && question.is_a?(ScoredQuestion)
        total_weight+=question.weight
      end
    end
    if scores.empty?
      questionnaire = questionnaire_by_answer(nil)
    else
      questionnaire = questionnaire_by_answer(scores.first)
    end
    total_weight*questionnaire.max_question_score
  end

  # Returns the total score from this response
  def get_alternative_total_score()
    # TODO The method get_total_score() above does not seem correct.  Replace with this method.
    total_score = 0

    self.scores.each { |score| total_score = total_score + score.score }

    total_score
  end

  # Function which considers a given assignment
  # and checks if a given review is still valid for score calculation
  # The basic rule is that
  # "A review is INVALID if there was new submission for the assignment
  #  before the most recent review deadline AND THE review happened before that
  #  submission"
  # response - the response whose validity is being checked
  # resubmission_times - submission times of the assignment is descending order
  # latest_review_phase_start_time
  # The function returns true if a review is valid for score calculation
  # and false otherwise
  def is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
    is_valid = true

    # if there was not submission then the response is valid
    if resubmission_times.nil? || latest_review_phase_start_time.nil?
      return is_valid
    end

    resubmission_times.each do |resubmission_time|
      # if the response is after a resubmission that is
      # before the latest_review_phase_start_time (check second condition below)
      # then we are good - the response is valid and we can break
      if (self.updated_at > resubmission_time.resubmitted_at)
        break
      end

      # this means there was a re-submission before the
      # latest_review_phase_start_time and we dont have a response after that
      # so the response is invalid
      if (resubmission_time.resubmitted_at < latest_review_phase_start_time)
        is_valid = false
        break
      end
    end

    is_valid
  end

  # only two types of responses more should be added
  def email (partial="new_submission")
    defn = Hash.new
    defn[:body] = Hash.new
    defn[:body][:partial_name] = partial
    response_map = ResponseMap.find map_id
    assignment=nil

    reviewer_participant_id =  response_map.reviewer_id
    participant = Participant.find(reviewer_participant_id)
    assignment = Assignment.find(participant.parent_id)

    if response_map.type =="ReviewResponseMap"

    end

    defn[:subject] = "A new submission is available for "+assignment.name
    if response_map.type == "ReviewResponseMap"
      defn[:body][:type] = "Author Feedback"
      AssignmentTeam.find(response_map.reviewee_id).users.each do |user|
        if assignment.has_topics?
          defn[:body][:obj_name] = SignUpTopic.find(SignedUpTeam.topic_id(assignment.id, user.id)).topic_name
        else
          defn[:body][:obj_name] = assignment.name
        end
        defn[:body][:first_name] = User.find(user.id).fullname
        defn[:to] = User.find(user.id).email
        Mailer.sync_message(defn).deliver
      end
    end
    if response_map.type == "MetareviewResponseMap"
      defn[:body][:type] = "Metareview"
      reviewee_user = Participant.find(response_map.reviewee_id)
      signup_topic_id = SignedUpTeam.topic_id(assignment.id, response_map.contributor.teams_users.first.user_id)

      defn[:body][:obj_name] = SignUpTopic.find(signup_topic_id).topic_name
      defn[:body][:first_name] = User.find(reviewee_user.user_id).fullname
      defn[:to] = User.find(reviewee_user.user_id).email
      Mailer.sync_message(defn).deliver
    end
    if response_map.type == "FeedbackResponseMap" #This is authors' feedback from UI
      defn[:body][:type] = "Review Feedback"
      # reviewee is a response, reviewer is a participant
      # we need to track back to find the original reviewer on whose work the author comments
      response_id_for_original_feedback = response_map.reviewed_object_id
      response_for_original_feedback = Response.find response_id_for_original_feedback
      response_map_for_original_feedback = ResponseMap.find response_for_original_feedback.map_id
      original_reviewer_participant_id = response_map_for_original_feedback.reviewer_id

      participant = AssignmentParticipant.find(original_reviewer_participant_id)
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      if topic_id.nil?
        defn[:body][:obj_name] = assignment.name
      else
        defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name
      end

      user = User.find(participant.user_id)

      defn[:to] = user.email
      defn[:body][:first_name] = user.fullname
      Mailer.sync_message(defn).deliver
    end
    if response_map.type == "TeammateReviewResponseMap"
      defn[:body][:type] = "Teammate Review"
      participant = AssignmentParticipant.find(response_map.reviewee_id)
      topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
      defn[:body][:obj_name] = SignUpTopic.find(topic_id).topic_name
      user = User.find(participant.user_id)
      defn[:body][:first_name] = user.fullname
      defn[:to] = user.email
      Mailer.sync_message(defn).deliver
    end
  end

  def questionnaire_by_answer (answer)
    if !answer.nil? # for all the cases except the case that  file submission is the only question in the rubric.
      questionnaire = Question.find(answer.question_id).questionnaire
    else
      # there is small possibility that the answers is empty: when the questionnaire only have 1 question and it is a upload file question
      # the reason is that for this question type, there is no answer record, and this question is handled by a different form
      map = ResponseMap.find(self.map_id)
      reviewer_participant = Participant.find(map.reviewer_id)
      assignment = Assignment.find(reviewer_participant.parent_id)
      questionnaire = Questionnaire.find(assignment.get_review_questionnaire_id)
    end
    questionnaire
  end
  require 'analytic/response_analytic'
  include ResponseAnalytic
  end
