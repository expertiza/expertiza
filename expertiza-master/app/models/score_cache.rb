class ScoreCache < ActiveRecord::Base
  
  ## makes an entry into score_cache table whenever a response is given/edited.
  ## handles team and individual assignments differently - for individual assignments the reviewee_id = participant.id, for team assignments, reviewee_id = team_id
  def self.update_cache(rid)
    @ass_id = 0
    @userset = []
    @team = 0
    @team_number = 0
    @teamass = 0
    @reviewmap = Response.find(rid).map_id  #find the map_id for this review
    @rm = ResponseMap.find(@reviewmap) #find the map for this review
    @participant1 = AssignmentParticipant.new
    @contributor_id = 0
    @map_type = @rm.type.to_s #find type of Response map
    @t_score = 0
    @t_min = 0
    @teammember = TeamsUser.new
    @t_max = 0
    
    if @map_type == "TeamReviewResponseMap"
      get_team_score()
    else
      get_participant_score()
    end
    update_score_cache()
    #########################
  end
    
  def self.get_team_score()
      @ass_id = @rm.reviewed_object_id
      @assignment1 = Assignment.find(@ass_id)
    @teammember =  TeamsUser.find(:first, :conditions => ["team_id = ?",@rm.reviewee_id])  #team which is being reviewed
      @participant1 = AssignmentParticipant.find(:first, :conditions =>["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id])
      @contributor_id = @teammember.team_id
    @questions = Hash.new
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
        |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    }
    team = Team.find(@contributor_id)
    @allscores = team.get_scores(@questions)
  end
      
  def self.get_participant_score()
    @participant1 = AssignmentParticipant.find(@rm.reviewee_id) # entire tuple with info of asgnment n participant
      @contributor_id = @participant1.id
      @assignment1 = Assignment.find(@participant1.parent_id)
      @ass_id = @assignment1.id
    @questions = Hash.new    
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    } 
    @allscores = @participant1.get_scores( @questions) # Return scores that this participant has given
    end
    
  def self.update_score_cache()
    @p_score = 0
    @p_min = 0
    @p_max = 0
    @scorehash = get_score_set_for_review_type(@allscores, @map_type) ##isolates the scores for the particular item needed
    
    @p_score = @scorehash[:avg]               
    @p_min = @scorehash[:min]
    @p_max = @scorehash[:max]
    
    sc = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  @contributor_id, @map_type ])
    if sc == nil
      @msgs = "first entry"
      sc = ScoreCache.new
      sc.reviewee_id = @contributor_id
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      sc.object_type = @map_type                        
      sc.save
      # make another new tuple for new score
    else
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      #presenceflag = 2
      sc.save
      #look for a consolidated score and change
    end               
  end

  def self.get_score_set_for_review_type(allscores, map_type)
    ##isolates the scores for the particular item needed  (eg: Review, MetaReview, Feedback etc)
    #  ParticipantReviewResponseMap - Review mappings for single user assignments
    #  TeamReviewResponseMap - Review mappings for team based assignments
    #  MetareviewResponseMap - Metareview mappings
    #  TeammateReviewResponseMap - Review mapping between teammates
    #  FeedbackResponseMap - Feedback from author to reviewer
    
    score_set = Hash.new
    if map_type == "ParticipantReviewResponseMap"
      if allscores[:review]
        score_set = compute_scoreset(allscores , "review")
      end
    elsif map_type == "TeamReviewResponseMap"
      if allscores[:review]
        score_set = compute_scoreset(allscores , "review")
      end
    
    elsif map_type == "TeammateReviewResponseMap"
      if allscores[:review]
        score_set = compute_scoreset(allscores , "teammate")
      end
      
    elsif map_type == "MetareviewResponseMap"
      if allscores[:metareview]
        score_set = compute_scoreset(allscores , "metareview")
      end
    elsif map_type == "FeedbackResponseMap"
      if allscores[:feedback]
        score_set = compute_scoreset(allscores , "feedback")
      end
    end 
    @scoreset = Hash.new
    @scoreset[:avg] = score_set[:avg]
    @scoreset[:min] = score_set[:min]
    @scoreset[:max] = score_set[:max]
    return @scoreset
  end
 
  def self.compute_scoreset(allscores , score_param)
    score_stat = Hash.new
    if score_param != nil && allscores[score_param.to_sym] != nil
      score_parameter = score_param.to_sym
      score_stat[:avg] = allscores[score_parameter][:scores][:avg]
      score_stat[:min] = allscores[score_parameter][:scores][:min]
      score_stat[:max] = allscores[score_parameter][:scores][:max]
    else
      score_stat[:avg] = nil
      score_stat[:min] = nil
      score_stat[:max] = nil
    end
    return score_stat
  end
end
