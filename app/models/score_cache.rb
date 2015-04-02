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
      tm_id=@contributor_id
    else
      get_participant_score()
      part = Participant.where(["id = ?", @rm.reviewee_id])
      tm_user=TeamsUser.where(["user_id = ?", part.user_id]).first
      tm_id=tm_user.team_id
    end
    update_score_cache()
    #########################
                                            # From here on to the end of this method is the algorithm of
                                            # score redistribution, for detailed algorithm, please check
                                            # the project documentation
    tm_user_ct = TeamsUser.where(["team_id = ?", tm_id])
    tm_rv_ct = ScoreCache.where(["reviewee_id = ? and object_type = ?", tm_id, "TeammateReviewResponseMap"]).count
    sc_proj = ScoreCache.where(["reviewee_id = ? and object_type = ?", tm_id, "TeamReviewResponseMap"]).first

    if tm_user_ct == tm_rv_ct and sc_proj != nil

      sc_cls = ScoreCache.where(["object_type = ?", "TeammateReviewResponseMap"])
      ct_cls = ScoreCache.where(["object_type = ?", "TeammateReviewResponseMap"]).count

      tm_rv_all = ScoreCache.where(["reviewee_id = ? and object_type = ?", tm_id, "TeammateReviewResponseMap"])


      avg_cls = 0
      sc_cls.each{|item| (avg_cls += item.score) if item}
      avg_cls /= ct_cls if ct_cls

      avg_tm = 0
      tm_max = 0
      tm_rv_all.each do |item|

        endavg_tm += item.score if item
        if item.score >tm_max
          tm_max = item.score
        end
      end
      avg_tm /= tm_user_ct  #avg_tm the average teammate review score of this team


      threshold = avg_tm  # the line of score to determine if a student needs to be punished or rewarded
      hardline = 85 # when the average of the whole team's teammate review is lower than the hardline but some of the students' teammate reviews are higher than hardline, hardline is used as threshold
      offset = 20 # determines how much points below the line begins the punishment
      rate = 0.5 # each point below threshold - offset will deduct the team review score of the student by 'rate'
      max_deduct = 10 # maximum deducted score a student could have
      use_cls = 0  # if the class average of teammate review score is used as the hardline
      if sc_th = ScoreCache.where(["reviewee_id = ? and object_type = ?", @assignment1.id,"HardLine"]).first
        hardline = sc_th.score
      end
      if sc_off = ScoreCache.where(["reviewee_id = ? and object_type = ?", @assignment1.id,"Threshold"]).first
        offset = sc_off.score
      end
      if sc_rate = ScoreCache.where(["reviewee_id = ? and object_type = ?", @assignment1.id,"RedisFactor"]).first
        rate = sc_rate.score
      end
      if sc_max = ScoreCache.where(["reviewee_id = ? and object_type = ?", @assignment1.id,"MaxDeduct"])
        max_deduct = sc_max.score
      end
      if sc_ifcls = ScoreCache.where(["reviewee_id = ? and object_type = ?", @assignment1.id,"IfClass"]).first
        use_cls = sc_ifcls.score
      end

      if use_cls
        hardline = avg_cls
      end

      if avg_tm < hardline and tm_max > hardline
        threshold = hardline
      end

      score_pool = 0
      total_plus = 0

      tm_rv_all.each do |item|
        teamrvsc = item.score
        if teamrvsc < (threshold - offset)
          sc_mod = ScoreCache.where(["reviewee_id = ? and reviewee_id = ? and object_type = ?", tm_id, item.reviewee_id, "ModifiedAssignmentScore"]).first
          if sc_mod == nil
            sc_mod = ScoreCache.new
          end
          if (threshold - offset - teamrvsc)*rate <= max_deduct
            sc_mod.score = sc_proj.score - (threshold - offset - teamrvsc)*rate
            score_pool += (threshold - offset - teamrvsc)*rate
          else
            sc_mod.score = sc_proj.score - max_deduct
            score_pool += max_deduct
          end
          sc_mod.range = sc_mod.score
          sc_mod.object_type = "ModifiedAssignmentScore"
          sc_mod.reviewee_id = item.reviewee_id
          #sc_mod.team_id = tm_id
          sc_mod.save


        elsif teamrvsc > threshold
          total_plus += (teamrvsc - threshold)
        else
          sc_mod = ScoreCache.where(["reviewee_id = ? and reviewee_id = ? and object_type = ?", tm_id, item.reviewee_id, "ModifiedAssignmentScore"]).first
          if sc_mod == nil
            sc_mod = ScoreCache.new
          end
          sc_mod.score = sc_proj.score
          sc_mod.range = sc_mod.score
          sc_mod.object_type = "ModifiedAssignmentScore"
          sc_mod.reviewee_id = item.reviewee_id
          #sc_mod.team_id = tm_id
          sc_mod.save
        end
      end

      tm_rv_all.each do |item|
        teamrvsc = item.score
        if teamrvsc > threshold
          sc_mod = ScoreCache.where(["reviewee_id = ? and reviewee_id = ? and object_type = ?", tm_id, item.reviewee_id, "ModifiedAssignmentScore"]).first
          if sc_mod == nil
            sc_mod = ScoreCache.new
          end

          sc_mod.score = sc_proj.score + score_pool*(teamrvsc - threshold)/total_plus
          sc_mod.range = sc_mod.score
          sc_mod.object_type = "ModifiedAssignmentScore"
          sc_mod.reviewee_id = item.reviewee_id
          #sc_mod.team_id = tm_id
          sc_mod.save
        end
      end

    end

    score_all = ScoreCache.where(["reviewee_id = ? and object_type = ?", tm_id, "ModifiedAssignmentScore"])
    ##################end###########################
  end

  def self.get_team_score()
    @ass_id = @rm.reviewed_object_id
    @assignment1 = Assignment.find(@ass_id)
    @teammember =  TeamsUser.where(["team_id = ?",@rm.reviewee_id]).first  #team which is being reviewed
    @participant1 = AssignmentParticipant.where(["user_id = ? and parent_id = ?", @teammember.user_id, @ass_id]).first
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

    sc = ScoreCache.where(["reviewee_id = ? and object_type = ?",  @contributor_id, @map_type ]).first
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
    @participant = AssignmentParticipant.find(pid)
    @participant_assignment_id = @participant.parent_id
    @all_participants = AssignmentParticipant.where(parent_id: @participant_assignment_id)

    individual_score = 0
    average_score = 0
    participant_count = 0
    minmax_hash = []

    @all_participants.find_each do |participant|
      individual_score = ScoreCache.find_by_reviewee_id(participant.id)
      if individual_score
        average_score = average_score+individual_score.score
        i = individual_score.score
        minmax_hash << i
        participant_count = participant_count + 1
      end
  end

  average_score /= participant_count if participant_count != 0
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

    assignment_num_reviews = ResponseMap.where(["reviewed_object_id=? AND type=?", @assignment_id, 'TeamReviewResponseMap'])
    @assignment_participants = AssignmentParticipant.where(parent_id: @assignment_id)

    count = 0
    @assignment_participants.each{count = count + 1}

    num_review_count=0.0
    assignment_num_reviews.each{num_review_count = num_review_count + 1.0}
    @avg_review_count=num_review_count/count

  end

  def self.get_metareviews_average(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id
    assignment_num_metareviews = ResponseMap.where(["reviewed_object_id=? AND type=?", @assignment_id, 'MetareviewResponseMap'])
    @assignment_participants = AssignmentParticipant.where(parent_id: @assignment_id)

    count = 0
    @assignment_participants.each{count = count + 1}

    num_metareview_count=0.0
    assignment_num_metareviews.each{num_metareview_count = num_metareview_count + 1.0}
    @average_metareviews = num_metareview_count/count
  end

  def self.my_reviews(pid)
    @participant = AssignmentParticipant.find(pid)
    @assignment_id = @participant.parent_id

    #@num_of_reviews = ResponseMap.where("reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'TeamReviewResponseMap')
    @num_of_reviews = ResponseMap.where(["reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'TeamReviewResponseMap'])

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

    @num_of_metareviews = ResponseMap.where(["reviewed_object_id=? AND reviewer_id = ? AND type=?", @assignment_id, @participant.id, 'MetareviewResponseMap'])

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
