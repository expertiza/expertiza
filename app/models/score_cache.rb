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
    @allscores = team.scores(@questions)
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
    @allscores = @participant1.scores( @questions) # Return scores that this participant has given
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


  def self.get_class_scores(pid)
=begin
    take average score of every student for that assignment
    find min and max from these
    calculate average class score for that assignment from this

    get number of reviews by each student for that assignment
    calculate the average from the above data

    get number of metareviews by each student for that assignment
    calculate the average from the above data

1. participant_id  from the view
2. participant ka parent_id (which is assignment_id) from participant table for that participant
3. get all participants from participant table for that parent_id
4. get scores for all tuples in score_caches where rewiewee_id == participants_ids from step 3 --- mapped to score_caches ka reviewee_id
=end

    @participant = AssignmentParticipant.find(pid)
    @participant_assignment_id = @participant.parent_id
    @all_participants = Hash.new
    @all_participants = AssignmentParticipant.find_all_by_parent_id(@participant_assignment_id)




    individual_score = 0
    average_score = 0
    participant_count = 0
    min_score = 101
    max_score = -1
    minmax_hash = Array.new


    for participant in @all_participants
      individual_score = ScoreCache.find_by_reviewee_id(participant.id)
      if(individual_score)

        average_score = average_score+individual_score.score


        i = individual_score.score
        minmax_hash << i
        participant_count = participant_count + 1
      end
      #if individual_score < min_score
      #  min_score = individual_score
      #end
      #if individual_score > max_score
      #  max_score = individual_score
      #end
    end

    average_score /= participant_count
    @result_hash = Array.new
    @result_hash[0] = average_score
    min_value = minmax_hash.min
    max_value = minmax_hash.max
    @result_hash[1]=min_value
    @result_hash[2]=max_value

    return @result_hash

  end


  def self.get_reviews_average(pid)

    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id

    assignment_num_reviews = Response.find(:all,:conditions => ["reviewed_object_id=? AND type=?", @assignment_id, 'TeamReviewResponseMap'])
    @assignment_participants = AssignmentParticipant.find_all_by_parent_id(@assignment_id)

    count = 0
    @assignment_participants.each{count = count + 1}

    num_review_count=0.0
    assignment_num_reviews.each{num_review_count = num_review_count + 1.0}
    @avg_review_count=num_review_count/count

  end

  def self.get_metareviews_average(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id
    assignment_num_metareviews = Response.find(:all,:conditions => ["reviewed_object_id=? AND type=?", @assignment_id, 'MetareviewResponseMap'])
    @assignment_participants = AssignmentParticipant.find_all_by_parent_id(@assignment_id)

    count = 0
    @assignment_participants.each{count = count + 1}

    num_metareview_count=0.0
    assignment_num_metareviews.each{num_metareview_count = num_metareview_count + 1.0}
    puts num_metareview_count
    @average_metareviews = num_metareview_count/count
  end

  def self.my_reviews(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id

    #@num_of_reviews = ResponseMap.where("reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'TeamReviewResponseMap')
    @num_of_reviews = Response.find(:all,:conditions => ["reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'TeamReviewResponseMap'])

    reviews_remaining = Array.new
    threshold = 2
    count = 0
    @num_of_reviews.each{count = count + 1}
    reviews_remaining[0] = count
    remaining = threshold-count
    reviews_remaining[1] = remaining
    return reviews_remaining
  end

  def self.my_metareviews(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id

    @num_of_metareviews = Response.find(:all,:conditions => ["reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'MetareviewResponseMap'])

    metaReviews_remaining = Array.new
    threshold=1
    count = 0
    @num_of_metareviews.each{count = count + 1}
    metaReviews_remaining[0] = count

    remaining=threshold-count
    metaReviews_remaining[1] = remaining
    return metaReviews_remaining
  end




end
