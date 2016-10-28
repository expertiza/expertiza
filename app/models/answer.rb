require 'analytic/score_analytic'

class Answer < ActiveRecord::Base
  include ScoreAnalytic
  belongs_to :question

  # Computes the total score for a *list of assessments*
  # parameters
  #  assessments - a list of assessments of some type (e.g., author feedback, teammate review)
  #  questions - the list of questions that was filled out in the process of doing those assessments
  def self.compute_scores(assessments, questions)
    scores = {}
    if !assessments.nil? && !assessments.empty?
      scores[:max] = -999_999_999
      scores[:min] = 999_999_999
      total_score = 0
      length_of_assessments = assessments.length.to_f
      assessments.each do |assessment|
        curr_score = get_total_score(response: [assessment], questions: questions)

        scores[:max] = curr_score if curr_score > scores[:max]
        if curr_score < scores[:min] and curr_score != -1
          scores[:min] = curr_score
        end

        # Check if the review is invalid. If is not valid do not include in score calculation
        if @invalid == 1 or curr_score == -1
          length_of_assessments -= 1
          curr_score = 0
        end
        total_score += curr_score
      end
      scores[:avg] = if length_of_assessments != 0
        total_score.to_f / length_of_assessments
      else
        0
                     end
    else
      scores[:max] = nil
      scores[:min] = nil
      scores[:avg] = nil
    end

    scores
  end

    # Computes the total score for an assessment
    # params
    #  assessment - specifies the assessment for which the total score is being calculated
    #  questions  - specifies the list of questions being evaluated in the assessment

  def self.get_total_score(params)
    @response = params[:response].last
    if @response
      @questions = params[:questions]

      weighted_score = 0
      sum_of_weights = 0
      max_question_score = 0

      @questionnaire = Questionnaire.find(@questions[0].questionnaire_id)

      questionnaireData = ScoreView.find_by_sql ["SELECT q1_max_question_score ,SUM(question_weight) as sum_of_weights,SUM(question_weight * s_score) as weighted_score FROM score_views WHERE type in('Criterion', 'Scale') AND q1_id = ? AND s_response_id = ?", @questions[0].questionnaire_id, @response.id]
      # zhewei: we should check whether weighted_score is nil,
      # which means student did not assign any score before save the peer review.
      # If we do not check here, to_f method will convert nil to 0, at that time, we cannot figure out the reason behind 0 point,
      # whether is reviewer assign all questions 0 or reviewer did not finish any thing and save directly.
      weighted_score = if !questionnaireData[0].weighted_score.nil?
        questionnaireData[0].weighted_score.to_f
      else
        nil
                       end
      sum_of_weights = questionnaireData[0].sum_of_weights.to_f
      # Zhewei: we need add questions' weights only their answers are not nil in DB.
      all_answers_for_curr_response = Answer.where(response_id: @response.id)
      all_answers_for_curr_response.each do |answer|
        question = Question.find(answer.question_id)
        # if a questions is a scored question (criterion or scale), the weight cannot be null.
        # Answer.answer is nil indicates that this scored questions is not filled. Therefore the score of this question is ignored and not counted
        # towards the score for this response.
        if answer.answer.nil? && question.is_a?(ScoredQuestion)
          question_weight = Question.find(answer.question_id).weight
          sum_of_weights -= question_weight
        end
      end
      max_question_score = questionnaireData[0].q1_max_question_score.to_f
      submission_valid?(@response)
      if sum_of_weights > 0 && max_question_score && !weighted_score.nil?
        return (weighted_score / (sum_of_weights * max_question_score)) * 100
      else
        return -1.0 # indicating no score
      end
    end
  end
    # Check for invalid reviews.
    # Check if the latest review done by the reviewer falls into the latest review stage

  def self.submission_valid?(response)
    if response
      map = ResponseMap.find(response.map_id)
      # assignment_participant = Participant.where(["id = ?", map.reviewee_id])
      @sorted_deadlines = nil
      @sorted_deadlines = AssignmentDueDate.where(parent_id: map.reviewed_object_id).order('due_at DESC')

      # to check the validity of the response
      if @sorted_deadlines.nil?

        # find the latest review deadline
        # less than current time
        flag = 0
        latest_review_phase_start_time = nil
        current_time = Time.new
        for deadline in @sorted_deadlines
          # if flag is set then we saw a review deadline in the
          # previous iteration - check if this deadline is a past
          # deadline
          if (flag == 1) && (deadline.due_at <= current_time)
            latest_review_phase_start_time = deadline.due_at
            break
          else
            flag = 0
          end

          # we found a review or re-review deadline - examine the next deadline
          # to check if it is past
          if deadline.deadline_type_id == 4 || deadline.deadline_type_id == 2
            flag = 1
          end
        end

        resubmission_times = ResubmissionTime.where(participant_id: map.reviewee_id).order('resubmitted_at DESC')
        @invalid = if response .is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
          0
        else
          1
                   end
        return @invalid
      end
    end
  end

  #start added by ferry, required for the summarization (refactored by Yang on June 22, 2016)
  def self.answers_by_question_for_reviewee_in_round(assignment_id, reviewee_id, q_id, round)
    #  get all answers to this question
    question_answer = Answer.select(:answer, :comments)
                          .joins("join responses on responses.id = answers.response_id")
                          .joins("join response_maps on responses.map_id = response_maps.id")
                          .joins("join questions on questions.id = answers.question_id")
                          .where("response_maps.reviewed_object_id = ? and
                                           response_maps.reviewee_id = ? and
                                           answers.question_id = ? and
                                           responses.round = ?", assignment_id, reviewee_id, q_id, round)
    return question_answer
  end

  def self.answers_by_question(assignment_id, q_id)
    question_answer = Answer.select("DISTINCT answers.comments,  answers.answer")
                          .joins("JOIN questions ON answers.question_id = questions.id")
                          .joins("JOIN responses ON responses.id = answers.response_id")
                          .joins("JOIN response_maps ON responses.map_id = response_maps.id")
                          .where("answers.question_id = ? and response_maps.reviewed_object_id = ?", q_id, assignment_id)
    return question_answer
  end

  def self.answers_by_question_for_reviewee(assignment_id, reviewee_id, q_id)
    question_answers = Answer.select(:answer, :comments)
                           .joins("join responses on responses.id = answers.response_id")
                           .joins("join response_maps on responses.map_id = response_maps.id")
                           .joins("join questions on questions.id = answers.question_id")
                           .where("response_maps.reviewed_object_id = ? and
                                                 response_maps.reviewee_id = ? and
                                                 answers.question_id = ? ", assignment_id, reviewee_id, q_id )
    return question_answers
  end
  # end added by ferry, required for the summarization

end
