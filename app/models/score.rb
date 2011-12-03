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
      assessments.each {
        | assessment | 
        curr_score = get_total_score(assessment, questions)

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
  def self.get_total_score(response, questions)
    weighted_score = 0
    sum_of_weights = 0
     @invalid=0
    #Check for invalid reviews.
    #Check if the latest review done by the reviewer falls into the latest review stage
    map=ResponseMap.find(response.map_id)
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

    questions.each{
      | question |
      item = Score.find_by_response_id_and_question_id(response.id, question.id)
      if item != nil
        weighted_score += item.score * question.weight
      end      
      sum_of_weights += question.weight
    }
     if due_dates.size!=0
    if(response.created_at > next_ele.due_at)
      @invalid=0
    else
      @invalid = 1
    end
    end
    return (weighted_score.to_f / (sum_of_weights.to_f * questions.first.questionnaire.max_question_score.to_f)) * 100

  end
end