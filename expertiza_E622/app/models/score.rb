class Score < ActiveRecord::Base
  belongs_to :question  
  
  # Computes the total score for a list of assessments
  # parameters
  #  assessments - a list of assessments of some type (e.g., author feedback, teammate review)
  #  questions - the list of questions that was filled out in the process of doing those assessments
  def self.compute_scores(assessments, questions)
    scores = Hash.new
    if assessments.length > 0
      scores[:max] = -999999999
      scores[:min] = 999999999
      total_score = 0
      length_of_assessments=assessments.length.to_f
      q_types = Array.new
      questions.each {
        | question |
        q_types << QuestionType.find_by_question_id(question.id)
      }
      assessments.each {
        | assessment |
        #questionnaire = Questionnaire.find(assessment.)

        curr_score = get_total_score(:response => assessment, :questions => questions, :q_types => q_types)

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
      if(length_of_assessments!=0)
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
  
  # Computes the total score for an assessment
  # params
  #  assessment - specifies the assessment for which the total score is being calculated
  #  questions  - specifies the list of questions being evaluated in the assessment

  def self.get_total_score(params)
    @response = params[:response]
    @questions = params[:questions]
    @q_types = params[:q_types]

    weighted_score = 0
    sum_of_weights = 0
     @invalid=0
    #Check for invalid reviews.
    #Check if the latest review done by the reviewer falls into the latest review stage
    map=ResponseMap.find(@response.map_id)
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?", map.reviewed_object_id])

    if due_dates.size!=0
      @sorted_deadlines=Array.new
      @sorted_deadlines=due_dates.sort {|m1,m2|(m1.due_at and m2.due_at) ? m2.due_at <=> m1.due_at : (m1.due_at ? -1 : 1)}
      flag=0
      for deadline in @sorted_deadlines
         next_ele=deadline
         if(flag==1)
            break
         end
         if(deadline.deadline_type_id == 4 ||deadline.deadline_type_id == 2)
           flag=1
         end
       end
    end

    @questionnaire = Questionnaire.find(@questions[0].questionnaire_id)

    x = 0
    if @questionnaire.section == "Custom" 
      @questions.each{
        | question |
        item = Score.find_by_response_id_and_question_id(@response.id, question.id)
        if @q_types.length <= x
          @q_types[x] = QuestionType.find_by_question_id(question.id)
        end

        if @q_types[x].q_type == "Rating"
          ratingPart = @q_types[x].parameters.split("::").last
          if ratingPart.split("|")[0] == "1"
            if(!item.nil?)
              weighted_score += item.comments.to_i * question.weight
              sum_of_weights += question.weight
            end
          end
        end
        x = x + 1
      }
    else
      @questions.each{
        | question |
        item = Score.find_by_response_id_and_question_id(@response.id, question.id)
        if item != nil
          weighted_score += item.score * question.weight
        end
        sum_of_weights += question.weight
    }
    end

     if due_dates.size!=0
    if(@response.created_at < next_ele.due_at)
      @invalid=0
    else
      @invalid = 1
    end
    end
    if(sum_of_weights > 0)
      return (weighted_score.to_f / (sum_of_weights.to_f * @questionnaire.max_question_score.to_f)) * 100
    else
      return -1 #indicating no score
    end
  end
end
