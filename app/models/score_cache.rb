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
    @the_object_id = 0
    @map_type = @rm.type.to_s
    @t_score = 0
    @t_min = 0
    @teammember = TeamsUser.new
    @t_max = 0
    @myfirst = "before"
    
    
    
    #if (@map_type == "ParticipantReviewResponseMap")
    if(@map_type == "TeamReviewResponseMap")
      @ass_id = @rm.reviewed_object_id
      @assignment1 = Assignment.find(@ass_id)
      @teammember =  TeamsUser.find(:first, :conditions => ["team_id = ?",@rm.reviewee_id])
      @participant1 = AssignmentParticipant.find(:first, :conditions =>["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id])
      @the_object_id = @teammember.team_id
      
    else
      @participant1 = AssignmentParticipant.find(@rm.reviewee_id)
      @the_object_id = @participant1.id
      @assignment1 = Assignment.find(@participant1.parent_id)
      @ass_id = @assignment1.id
      
      
    end 
    @questions = Hash.new    
    questionnaires = @assignment1.questionnaires
    questionnaires.each{
      |questionnaire|
      @questions[questionnaire.symbol] = questionnaire.questions
    } 
    @allscores = @participant1.get_scores( @questions)
    
    @scorehash = get_my_scores(@allscores, @map_type) 
    
    
    @p_score = @scorehash[:avg]               
    @p_min = @scorehash[:min]
    @p_max = @scorehash[:max]
    
    sc = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  @the_object_id, @map_type ])
    if ( sc == nil)
      presenceflag = 1
      @msgs = "first entry"
      sc = ScoreCache.new
      sc.reviewee_id = @the_object_id
      # sc.assignment_id = @ass_id
      
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      
      # added code to update the max and min values...SRS 10312010
      sc.range_max = (@p_max*100).round/100.0
      sc.range_min = (@p_min*100).round/100.0
      sc.range =    range_string
      sc.score = (@p_score*100).round/100.0
      
      sc.object_type = @map_type                        
      
      sc.save
      # make another new tuple for new score
    else
      range_string = ((@p_min*100).round/100.0).to_s + "-" + ((@p_max*100).round/100.0).to_s
      
      # added code to update the max and min values...SRS 10312010
      sc.range_max = (@p_max*100).round/100.0
      sc.range_min = (@p_min*100).round/100.0
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

  def self.get_participant_score(participant, assgtid, type)
    scores = Hash.new
    assgt = Assignment.find(assgtid)
    
    if type == 'Review'
      if assgt[:team_assignment]
        type = 'ParticipantReviewResponseMap'
      else
        type = 'TeamReviewResponseMap'
      end
    elsif type == 'Metareview'
      type = 'MetareviewResponseMap'
    elsif type == 'AuthorFeedback'
      type = 'FeedbackResponseMap'
    elsif type == 'TeammateReview'
      type = 'TeammateReviewResponseMap'
    else
      type = 'ParticipantReviewResponseMap'
    end
    
    if assgt[:team_assignment]
      assignment_teams = Team.find(:all, 
             :conditions => ["parent_id = ? and type = ?", assgt.id, 'AssignmentTeam']) 
      participant_entries = ScoreCache.find(:all, 
             :conditions =>["reviewee_id in (?) and object_type = ?", assignment_teams, type ])
    else
      participant_entries = ScoreCache.find(:all, 
             :conditions =>["reviewee_id in (?) and object_type = ?", participant, type])
    end
       
    if participant_entries != nil
       scores = Hash.new
       for participant_entry in participant_entries
          scores[:max] = participant_entry.range_max
          scores[:min] = participant_entry.range_min
          scores[:avg] = participant_entry.score
       end
    else
       scores[:max] = nil
       scores[:min] = nil
       scores[:avg] = nil
    end
    return scores 
  end
end
