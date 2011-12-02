class Score < ActiveRecord::Base
  belongs_to :question


  #avalent
  # Same as compute_scores(assessments, questions) but it first checks if the score is available in the ScoreCache.
  # If the score is in the cache it'll get it from the cache, otherwise it'll call compute_scores(assessments, questions)
  # The parameters reviewee_id and object_type are used to look for the score in the cache.
  def self.get_scores(assessments, questions, reviewee_id, object_type)
    scores = Hash.new
    sc = nil
    if assessments.length > 0
      sc = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", reviewee_id, object_type])
      if sc == nil
        ScoreCache.update_cache(response.id)
        sc = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", reviewee_id, cache_map_type])
        range = sc.range.split('-')
        scores[:max] = range[1].to_f
        scores[:min] = range[0].to_f
        scores[:avg] = sc.score
      else
        scores[:max] = nil
        scores[:min] = nil
        scores[:avg] = nil
      end
    end
    return scores
  end

  def self.get_cache_map_type(questionnaire_type)
    map_type = nil
    case questionnaire_type
      when "ReviewQuestionnaire"
        map_type = "ParticipantReviewResponseMap"
      when "MetareviewQuestionnaire"
        map_type = "MetareviewResponseMap"
      when "AuthorFeedbackQuestionnaire"
        map_type = "FeedbackResponseMap"
      when "TeammateReviewQuestionnaire"
        map_type = "TeammateReviewResponseMap"
    end
    return map_type
  end

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
      assessments.each {
        | assessment |
        curr_score = get_total_score(assessment, questions)
        if curr_score > scores[:max]
          scores[:max] = curr_score
        end
        if curr_score < scores[:min]
          scores[:min] = curr_score
        end
        total_score += curr_score
      }
      scores[:avg] = total_score.to_f / assessments.length.to_f
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
    questions.each{
      | question |
      item = Score.find_by_response_id_and_question_id(response.id, question.id)
      if item != nil
        weighted_score += item.score * question.weight
      end      
      sum_of_weights += question.weight
    }
    return (weighted_score.to_f / (sum_of_weights.to_f * questions.first.questionnaire.max_question_score.to_f)) * 100   
  end

  def self.get_total_score_from_cache(response, questions)
    reviewee_id = response.map.reviewee_id
    cache_map_type = response.map.type
    sc = nil
    if questions.length > 0
      sc = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", reviewee_id, cache_map_type])
    end
    if sc == nil
      ScoreCache.update_cache(response.id)
      sc = ScoreCache.find(:first, :conditions => ["reviewee_id = ? and object_type = ?", reviewee_id, cache_map_type])
    end
    return sc.score
  end

  #Override ActiveRecord::Base's update_attribute and create methods so that ScoreCache is updated simultaneously
  def update_attribute(name, value)   
    ScoreCache.update_cache(response_id)
    super.update_attribute(name,value)  
  end

  def create(attributes = nil, &block)
    ScoreCache.update_cache(response_id)
    super.create(attributes,&block)
  end   
end