class ScoreCache < ActiveRecord::Base
  
  ## makes an entry into score_cache table whenever a response is given/edited.
  ## handles team and individual assignments differently - for individual assignments the reviewee_id = participant_id, for team assignments, reviewee_id = team_id
  def self.update_cache(rid)
    
    presenceflag = 0
    @ass_id = 0
    @userset = []
    @team = 0
    @team_number = 0
    @teamass = 0
    @reviewmap = Response.find(rid).map_id
    @rm = ResponseMap.find(@reviewmap)
    @participant1 = AssignmentParticipant.new
    @contributor_id = 0
    @map_type = @rm.type.to_s
    @t_score = 0
    @t_min = 0
    @teammember = TeamsParticipant.new
    @t_max = 0
    @myfirst = "before"
    
    
    
    #if (@map_type == "ParticipantReviewResponseMap")
    if(@map_type == "TeamReviewResponseMap")
      @ass_id = @rm.reviewed_object_id
      @assignment1 = Assignment.find(@ass_id)
      @teammember =  TeamsParticipant.find(:first, :conditions => ["team_id = ?",@rm.reviewee_id])
      @participant1 = AssignmentParticipant.find(:first, :conditions =>["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id])
      @contributor_id = @teammember.team_id
      
    else
      @participant1 = AssignmentParticipant.find(@rm.reviewee_id)
      @contributor_id = @participant1.id
      @assignment1 = Assignment.find(@participant1.parent_id)
      @ass_id = @assignment1.id
      
      
    end 
    @questions = Hash.new    
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    } 
    # scores that participant1 has given
    if(@map_type == "TeamReviewResponseMap")
      team = Team.find(@contributor_id)
      @allscores = team.get_scores( @questions)
    else
      @allscores = @participant1.get_scores( @questions)
    end
    
    @scorehash = get_my_scores(@allscores, @map_type) 
    
    
    @p_score = @scorehash[:avg]               
    @p_min = @scorehash[:min]
    @p_max = @scorehash[:max]
    
    sc = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  @contributor_id, @map_type ])
    if ( sc == nil)
      presenceflag = 1
      @msgs = "first entry"
      sc = ScoreCache.new
      sc.reviewee_id = @contributor_id
      # sc.assignment_id = @ass_id
      
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
      presenceflag = 2
      sc.save
      #look for a consolidated score and change
    end               
    
   
    #########################
  end

  def self.get_my_scores( scorehash, map_type)
    ##isolates the scores for the particular item needed
    @p_score = 0
    @p_min = 0  
    @p_max = 0
    
    #  ParticipantReviewResponseMap - Review mappings for single user assignments
    #  TeamReviewResponseMap - Review mappings for team based assignments
    #  MetareviewResponseMap - Metareview mappings
    #  TeammateReviewResponseMap - Review mapping between teammates
    #  FeedbackResponseMap - Feedback from author to reviewer
    
    
    if(map_type == "ParticipantReviewResponseMap")
      
      if (scorehash[:review])
        @p_score = scorehash[:review][:scores][:avg]               
        @p_min = scorehash[:review][:scores][:min]
        @p_max = scorehash[:review][:scores][:max]
      end
    elsif (map_type == "TeamReviewResponseMap")
      if (scorehash[:review])
        @p_score = scorehash[:review][:scores][:avg]               
        @p_min = scorehash[:review][:scores][:min]
        @p_max = scorehash[:review][:scores][:max]
      end
      
    elsif (map_type == "TeammateReviewResponseMap")
      if (scorehash[:review])
        @p_score = scorehash[:teammate][:scores][:avg]               
        @p_min = scorehash[:teammate][:scores][:min]
        @p_max = scorehash[:teammate][:scores][:max]
      end
      
    elsif (map_type == "MetareviewResponseMap")
      if (scorehash[:metareview])
        @p_score = scorehash[:metareview][:scores][:avg]               
        @p_min = scorehash[:metareview][:scores][:min]
        @p_max = scorehash[:metareview][:scores][:max]
      end
    elsif (map_type == "FeedbackResponseMap")
      if (scorehash[:feedback])
        @p_score = scorehash[:feedback][:scores][:avg]               
        @p_min = scorehash[:feedback][:scores][:min]
        @p_max = scorehash[:feedback][:scores][:max]
      end
    end 
    @scoreset = Hash.new
    @scoreset[:avg] = @p_score
    @scoreset[:min] = @p_min
    @scoreset[:max] = @p_max
    return @scoreset
  end
 
end
