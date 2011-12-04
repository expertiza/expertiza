require File.dirname(__FILE__) + '/../test_helper'

class ScoreCacheTest < ActiveSupport::TestCase
  # We have tried hard to implement this fixtures and then populating a database on
  # the fly, but to get things moving we ended up just using the test_db.sql dump.
  # So rather than running rake, which clears the test database,to run these tests
  # you must first load the test_db.sql file into pg_test
  # and run using ruby test/unit/score_cache_test.rb
  def setup

    # These next few lines (only)  are specific to the test_db dump so they have to be
    # changed if you are using a different database or fixtures
    @assignment_id= 308  #a team assignment ("Final Project")
    @existingUser_id= 2140 #a user participating in the assignment
    @otherUser_id = 44 #a user not participating in the assignment or User.create()

    @assignment = Assignment.find(@assignment)
    @existingUser = User.find(@existingUser_id)
    @otherUser = User.find(@other_id)
    @existingParticipant = Participant.find(:first,
                              :conditions => ["user_id = ? and parent_id= ?", @existingUser.id, @assignment.id] )

    @existingTeam = @existingParticipant.team
    @newParticipant = Participant.create(:user_id => @user_id,
                                            :parent_id => @assignment_id).id
    TeamsUser.create(:team_id => @newTeam_id, :user_id => @user_id)
  end
  # if a cache for a set of responses doesn't exist, test_update creates it

  def test_update_cache_creates_new_cache
    count = ScoreCache.count
    sc = ScoreCache.destroy ScoreCache.first
    assert ScoreCache.count == count-1
    map_id = ResponseMap.find(:first, :conditions => ["reviewee_id = ?", sc.reviewee_id], :select=>:id)
    rid = Response.find(:first, :conditions => ["map_id = ?", map_id], :select=>:id)
    ScoreCache.update_cache(rid)
    assert ScoreCache.count == count
    ScoreCache.update_cache(rid)
    assert ScoreCache.count == count

    end
  end

  #This method will compare the results of obtained using the existing score.compute_scores with those of update_cache
  def test_update_cache_correctly_calculates_score_and_range_on_new_response

    @questionnaires = @assignment.questionnaires
    @questionnaires.each do { |@questionnaire|
        questions = @questionnaire.questions
        assessments = Response.all(:joins => :map,
        :conditions => [:response_maps => {:reviewee_id => @existingTeam.id, :type => 'TeamReviewMap'}])
        Score.compute_scores(questions,assessments)
    end
  end
=begin
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
end
