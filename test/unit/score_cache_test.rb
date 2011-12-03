require File.dirname(__FILE__) + '/../test_helper'

class ScoreCacheTest < ActiveSupport::TestCase
  
  # We have tried hard to implement with fixtures and then without fixtures or 
  # the populated db, but to get things moving we ended up having to use the 
  # test_db.sql dump. So rather than running rake, which clears the test database,
  # you must run
  def setup
    # Only these next few lines are specific to the test_db dump so they have to be
    # changed if you are using a different database, and can later be replaced by fixtures
    @assignment_id = 308  #Final Project
    @existingParticipant_id = 11458 #user 2140 on assgt 308
    @ReviewQuestionnaire_id = 14 
    @user_id = 44

    @newParticipant_id = Participant.create(:user_id => @user_id,
                                            :parent_id => @assignment_id ).id
    @newTeam_id = Team.create(:name=> "sctest team", :parent_id => @assignment_id).id
    TeamsUser.create(:team_id => @newTeam_id, :user_id => @user_id)
  end

  def test_update_cache_correctly_updates_existing_review
    sc = ScoreCache.find(:first)
    sc = ScoreCache.find()
    range = sc.range
    if sc.score =
  end
  def test_update_cache_creates_new_scorecache_correctly_for_first_reviews

    map = ResponseMap.create(:reviewed_object_id => @assignment_id,
                              :reviewer_id => @existingParticipant_id , 
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

  
end
