class Answer < ActiveRecord::Base
  belongs_to :question

  # Computes the total score for a *list of assessments*
  # parameters
  #  assessments - a list of assessments of some type (e.g., author feedback, teammate review)
  #  questions - the list of questions that was filled out in the process of doing those assessments
  def self.compute_scores(assessments, questions)
    scores = Hash.new
    if !assessments.nil?&&assessments.length > 0
      scores[:max] = -999999999
      scores[:min] = 999999999
      total_score = 0
      length_of_assessments=assessments.length.to_f
      assessments.each { |assessment|

        curr_score = get_total_score(:response => [assessment], :questions => questions)

        if curr_score > scores[:max]
          scores[:max] = curr_score
        end
        if curr_score < scores[:min]
          scores[:min] = curr_score
        end

        # Check if the review is invalid. If is not valid do not include in score calculation
        if  @invalid==1
          length_of_assessments=length_of_assessments-1
          curr_score=0
        end
        total_score += curr_score
      }
      if (length_of_assessments!=0)
        scores[:avg] = total_score.to_f / length_of_assessments
      else
        scores[:avg]=0
      end
    else
      scores[:max] = nil
      scores[:min] = nil
      scores[:avg] = nil
    end

    return scores
  end

    def self.compute_quiz_scores(responses)
      scores = Hash.new
      if responses.length > 0
        scores[:max] = -999999999
        scores[:min] = 999999999
        total_score = 0
        responses.each {
          | response |
          questions = QuizQuestionnaire.find(response.map.reviewed_object_id).questions
          curr_score = get_total_score(response, questions)
          if curr_score > scores[:max]
            scores[:max] = curr_score
          end
          if curr_score < scores[:min]
            scores[:min] = curr_score
          end
          total_score += curr_score
        }
        scores[:avg] = total_score.to_f / responses.length.to_f
      else
        scores[:max] = nil
        scores[:min] = nil
        scores[:avg] = nil
      end
      return scores
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

        questionnaireData = ScoreView.find_by_sql ["SELECT q1_max_question_score ,SUM(question_weight) as sum_of_weights,SUM(question_weight * s_score) as weighted_score FROM score_views WHERE type in('Criterion', 'Scale') AND q1_id = ? AND s_response_id = ?",@questions[0].questionnaire_id,@response.id]
        weighted_score = questionnaireData[0].weighted_score.to_f
        sum_of_weights = questionnaireData[0].sum_of_weights.to_f
        #Zhewei: we need add questions' weights only their answers are not nil in DB.
        all_answers_for_curr_response = Answer.where(response_id: @response.id)
        all_answers_for_curr_response.each do |answer|
          question = Question.find(answer.question_id)
          # if a questions is a scored question (criterion or scale), the weight cannot be null.
          # Answer.answer is nil indicates that this scored questions is not filled. Therefore the score of this question is ignored and not counted
          # towards the score for this response.
          if answer.answer.nil? && question.instance_of?(ScoredQuestion)
            question_weight = Question.find(answer.question_id).weight
            sum_of_weights -= question_weight
          end
        end
        max_question_score = questionnaireData[0].q1_max_question_score.to_f
        submission_valid?(@response)

        if (sum_of_weights > 0 && max_question_score)
          return (weighted_score / (sum_of_weights * max_question_score)) * 100
        else
          return -1.0 #indicating no score
        end
      end
    end
    #Check for invalid reviews.
    #Check if the latest review done by the reviewer falls into the latest review stage

    def self.submission_valid?(response)
      if response
        map=ResponseMap.find(response.map_id)
        #assignment_participant = Participant.where(["id = ?", map.reviewee_id])
        @sorted_deadlines = nil
        @sorted_deadlines = DueDate.where(["assignment_id = ?", map.reviewed_object_id]).order('due_at DESC')

        # to check the validity of the response
        if @sorted_deadlines.nil?

          #find the latest review deadline
          #less than current time
          flag = 0
          latest_review_phase_start_time = nil
          current_time = Time.new
          for deadline in @sorted_deadlines
            # if flag is set then we saw a review deadline in the
            # previous iteration - check if this deadline is a past
            # deadline
            if ((flag == 1) && (deadline.due_at <= current_time))
              latest_review_phase_start_time = deadline.due_at
              break
            else
              flag = 0
            end

            # we found a review or re-review deadline - examine the next deadline
            # to check if it is past
            if (deadline.deadline_type_id == 4 ||deadline.deadline_type_id == 2)
              flag = 1
            end
          end

          resubmission_times =   ResubmissionTime.where(participant_id: map.reviewee_id).order('resubmitted_at DESC')
          if response .is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
            @invalid = 0
          else
            @invalid = 1
          end
          return @invalid
        end
      end
    end

    require 'analytic/score_analytic'
    include ScoreAnalytic
  end
