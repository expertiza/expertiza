require File.dirname(__FILE__) + '/../test_helper'

class ScoreCacheTest < ActiveSupport::TestCase
  # We have tried hard to implement this with fixtures and then populating a database on
  # the fly, but to get things moving we ended up just using the test_db.sql dump.
  # So rather than running rake, which clears the test database,to run these tests
  # you must first load the test_db.sql file into pg_test
  # and run using ruby test/unit/score_cache_test.rb
  def setup
    # These next few lines (only)  are specific to the test_db dump so they have to be
    # changed if you are using a different database or fixtures

    team_assignment_id= 308  #a team assignment ("Final Project")
    teamUser_id= 2140 #a user participating in the assignment
    otherUser_id = 44 #a user not participating in the assignment or User.create()
    individualAssignment_id = 205 #an individual assignment ("GLP Final Paper")
    individualUser_id = 928  #a user participating in the individual assignment


    @teamAssignment = Assignment.find(team_assignment_id)
    @individualAssignment= Assignment.find(individualAssignment_id)
    @teamUser = User.find(teamUser_id)
    @individualUser = User.find(individualUser_id)
    @teamParticipant = Participant.first(
             :conditions => ["user_id = ? and parent_id = ?", @teamUser.id, @teamAssignment.id] )
    @individualParticipant = Participant.first(
             :conditions => ["user_id = ? and parent_id= ?", @individualUser.id, @individualAssignment.id] )

    @team = @teamParticipant.team
    @newParticipant = Participant.create(:user_id => @user_id,
                                            :parent_id => @assignment_id).id

  end


  # if a cache for a set of responses doesn't exist, update_cache should create it
  def test_update_cache_creates_new_cache
    count = ScoreCache.count
    sc = ScoreCache.destroy ScoreCache.first
    assert ScoreCache.count == count-1
    map = TeamReviewResponseMap.first(:conditions => ["reviewee_id = ? and type = ?", sc.reviewee_id, sc.object_type])
    rid = map.response_id
    ScoreCache.update_cache(rid)
    assert ScoreCache.count == count
    #otherwise it shouldn't create a new one
    ScoreCache.update_cache(rid)
    assert ScoreCache.count == count
  end



#Testing for accuracy (compared to scores.compute_scores currently used) of the scorecache for team review responses
  def test_update_cache_calculates_team_scores_correctly
   #calculating the scores the old-fashioned way
   assessments = Response.all(:joins => :map,
         :conditions => {:response_maps => {:reviewee_id => @team.id, :type => 'TeamReviewResponseMap'}})
   questionnaire = assessments[0].map.questionnaire
   questions = questionnaire.questions
   scores = Score.compute_scores(assessments, questions)

   #now recalculate and retrieve the cache
   ScoreCache.destroy(
       ScoreCache.all([:conditions => {:reviewee_id => @team.id, :object_type => 'TeamReviewResponseMap'}]))
   rid = assessments[0].id
   ScoreCache.update_cache(rid)
   sc = ScoreCache.find(:first,:conditions => {:reviewee_id => @team.id, :object_type => 'TeamReviewResponseMap'})

   assert sc.score == (scores[:avg]*100).round/100.0
   assert sc.range ==  ((scores[:min]*100).round/100.0).to_s + "-" + ((scores[:max]*100).round/100.0).to_s
  end

  def test_update_cache_calculates_the_other_scores_correctly

    questionnaires = @individualAssignment.questionnaires
    questionnaires.each do |questionnaire|
      maptype = Score::QUESTIONNAIRE_TYPE_CACHE_MAP_TYPE[questionnaire.type]
      #calculating the scores the old-fashioned way
      assessments = Response.all(:joins => :map,
         :conditions => {:response_maps => {:reviewee_id => @individualParticipant.id, :type => maptype}})
      questions = questionnaire.questions
      scores = Score.compute_scores(assessments, questions)

      #now recalculate and retrieve the cache
      ScoreCache.destroy(
         ScoreCache.all([:conditions => {:reviewee_id => @individualParticipant.id, :object_type => maptype }]))
      if assessments[0]
        rid = assessments[0].id
        ScoreCache.update_cache(rid)
        sc = ScoreCache.find(:first,:conditions => {:reviewee_id => @individualParticipant.id, :object_type => maptype})
        if sc
          assert sc.score == (scores[:avg]*100).round/100.0
          assert sc.range ==  ((scores[:min]*100).round/100.0).to_s + "-" + ((scores[:max]*100).round/100.0).to_s
        end
      end
    end
 end

end
=begin



#Testing for existence and accuracy (compared to scores.compute_scores currently used) of the scorecache for participant review responses
  def test_update_cache_calculates_maps_correctly
    questionnaires = @individualAssignment.questionnaires
    questionnaires.each do
            |questionnaire|
      maptype = Score.get_cache_map_type(questionnaire.type)

      #calculating the scores the old-fashioned way
      assessments = Response.all(:joins => :map,
           :conditions => {:response_maps => {:reviewee_id => @individualParticipant.id, :type => maptype}})
      if assessments.length > 0
        questions = questionnaire.questions
        scores = Score.compute_scores(assessments, questions)

        #now recalculate and retrieve the cache
        sc = ScoreCache.first([:conditions => {:reviewee_id => @individualParticipant.id, :object_type => maptype}])
        ScoreCache.destroy(sc.id)
        rid = assessments[0].id
        ScoreCache.update_cache(rid)
        ScoreCache.update_cache(rid)
        sc = ScoreCache.find(:first,:conditions => {:reviewee_id => @individualParticipant.id, :object_type => maptype})

        assert sc.score == (scores[:avg]*100).round/100.0
        assert sc.range ==  ((scores[:min]*100).round/100.0).to_s + "-" + ((scores[:max]*100).round/100.0).to_s
      end
    end
  end


end

  def test_update_cache_correctly_updates_score_and_range_on_edited_response

    assert ScoreCache.count == count-1

    map = ResponseMap.find(:first, :conditions => ["reviewee_id = ?", sc.reviewee_id])

    rid = Response.find(:first, :conditions => ["map_id = ?", map_id], :select=>:id)
    ScoreCache.update_cache(rid)
    assert ScoreCache.count == count
  end
  #delete a scorecache
    sc = ScoreCache.destroy ScoreCache.first
    #use the Score.compute_scores to find the score
    map_id = ResponseMap.find(:join => Respnse:all, :conditions => ["reviewee_id = ?", sc.reviewee_id], :select=>:id)
    assessments = Response.find

    #get computed_scores
    assessments = Response.find(:all, :conditions => ["map_id = ?", map_id], :select=>:id)

    #
    assessments = Response.find(:all, :conditions => ["compute_scores = ?"])
    ScoreCache.update_cache(rid)
    map = ResponseMap.create(:reviewed_object_id => @assignment_id,
                              :reviewer_id => @existingParticipant_id,
                              :reviewee_id => @newTeam_id )

    response = Response.create(:map_id => map.id)
    questions = Question.find_all_by_questionnaire_id(
        @ReviewQuestionnaire_id )
    puts questions
    puts ScoreCache.count
    questions.each do |question|
        puts question
        Score.create_score(:question_id=>question.id,
                   :score => 3,
                   :response_id=>response.id)
    end
    puts ScoreCache.count
    sc = ScoreCache.find(:first,:conditions=> ["reviewee_id = ? and object_type= ?", @newTeam_id,"ParticipantReviewResponse" ])
    assert sc.score == 60.0
    assert sc.range == "60.0-60.0"
 end
end


#  def test_update_score_updates_scorecache_correctly_for_new_reviews
#    map = ResponseMap.create!(:reviewed_object_id => @assignment_id,
#                              :reviewer_id => @existingParticipant_id ,
#                              :reviewee_id => @newTeam_id )
#    response = Response.create!(:map_id => map.id)
#    questions = Question.find_all_by_questionnaire_id(
#          @ReviewQuestionnaire_id )
#    puts questions
#    questions.each do |question|
#        puts question
#        Score.create(:question_id=>question.id,
#                   :score => 3,
#                   :response_id=>response.id)
#    end
#    sc = ScoreCache.find(:first, :conditions=> ["reviewee_id = ?", @newParticpant_id])
#    assert sc.score == 60
#    assert sc.range == "60.0-60.0"

#  end

#  def test_update_score_updates_scorecache_correctly_for_new_reviews
#    map = ResponseMap.create!(:reviewed_object_id => @assignment_id,
#                              :reviewer_id => @existingParticipant_id ,
#                              :reviewee_id => @newTeam_id )
#    response = Response.create!(:map_id => map.id)
#    questions = Question.find_all_by_questionnaire_id(
#          @ReviewQuestionnaire_id )
#    puts questions
#    questions.each do |question|
#        puts question
#        Score.create(:question_id=>question.id,
#                   :score => 3,
#                   :response_id=>response.id)
#    end
#    sc = ScoreCache.find(:first, :conditions=> ["reviewee_id = ?", @newParticpant_id])
#    assert sc.score == 60
#    assert sc.range == "60.0-60.0"

=end

