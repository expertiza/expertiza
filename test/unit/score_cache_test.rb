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
    sc = ScoreCache.destroy ScoreCache.first(:conditions => {:reviewee_id=>@team.id})
    assert ScoreCache.count == count-1
    map = TeamReviewResponseMap.first(:conditions => ["reviewee_id = ? and type = ?", sc.reviewee_id, sc.object_type])
    rid = map.response.id
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

  #Testing for accuracy (compared to scores.compute_scores currently used) of the scorecache for other
  def test_update_cache_calculates_the_other_scores_correctly
    questionnairemap = {
      "ReviewQuestionnaire" => "ParticipantReviewResponseMap",
      "MetareviewQuestionnaire" => "MetareviewResponseMap",
      "AuthorFeedbackQuestionnaire" => "FeedbackResponseMap",
      "TeammateReviewQuestionnaire" => "TeammateReviewResponseMap"
        }
  
    questionnaires = @individualAssignment.questionnaires             
    
    questionnaires.each do |questionnaire|
      maptype = questionnairemap[questionnaire.type]
      questions = questionnaire.questions      

      #calculating the scores the old-fashioned way
      assessments = Response.all(:joins => :map,
                    :conditions => {:response_maps => {:reviewee_id => @individualParticipant.id, 
                                                       :type => maptype}})

      scores = Score.compute_scores(assessments, questions)

      #now recalculate via update_cache and retrieve the cache
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
