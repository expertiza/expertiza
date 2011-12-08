require File.dirname(__FILE__) + '/../test_helper'
class ScoreTest < ActiveSupport::TestCase
  def setup
    @assignment_id = 308  #Final Project
    @existingParticipant_id = 11458 #name2140 on assgt 308
    @existingTeam_id =  2699  #a team on assignment 308
    @reviewQuestionnaire_id = 14

    @user_id = 44
    @assignment = Assignment.find(@assignment_id)
    @newParticipant_id = Participant.create(:user_id => @user_id,
                                            :parent_id => @assignment_id ).id
    @newTeam_id = AssignmentTeam.create(:name=> "stest team", :parent_id => @assignment_id ).id
    TeamsUser.create(:team_id => @newTeam_id, :user_id => @user_id)
  end

  # Call to get_scores with no assessments should return nils.
  def test_get_scores_nils
    assessments_empty = Array.new
    assessments = Response.all(:joins => :map,
           :conditions => {:response_maps => {:reviewee_id =>@existingTeam_id , :type => 'TeamReviewResponseMap'}})
    questionnaire = assessments[0].map.questionnaire
    questions = questionnaire.questions
    reviewee_id = @existingTeam_id
    object_type = 'TeamReviewResponseMap'
    scores1 = Score.get_scores(assessments_empty, questions)
    assert scores1[:max] == nil
    assert scores1[:min] == nil
    assert scores1[:avg] == nil

  end



  #with valid input, get_score should produce the same output as the existing compute_score
  def test_get_score_matches_compute_score
    map = TeamReviewResponseMap.create(:reviewed_object_id => @assignment_id,
                                       :reviewer_id => @existingParticipant_id,
                                       :reviewee_id => @newTeam_id)

    response = Response.create(:map_id => map.id)
    questions = Question.find_all_by_questionnaire_id(@reviewQuestionnaire_id)
    questions.each { |question|
      a = Score.create(:question_id=>question, :response_id=>response.id,:score=> 3)
      ScoreCache.update_cache(response.id)
    }
    assessments = Response.all(:joins => :map,
           :conditions => {:response_maps => {:reviewee_id =>@newTeam_id , :type => 'TeamReviewResponseMap'}})

    assert (Score.compute_scores(assessments,questions)  ==
             Score.get_scores(assessments,questions))

  end

  def test_update_attribute_updates_score
  # test whether score.update_attribute correctly updates the score
    maptype = "TeamReviewResponseMap"
    map = TeamReviewResponseMap.create(:reviewed_object_id => @assignment_id,
                                 :reviewer_id => @existingParticipant_id,
                                 :reviewee_id => @newTeam_id)
    response = Response.create(:map_id => map.id)
    question = Question.find_by_questionnaire_id(@reviewQuestionnaire_id)
    a = Score.create(:question_id=>question.id, :response_id=>response.id,:score=> 3)
    a.update_attribute('score', 4)
    assert a.score == 4
  end

  # test that update_cache is being called in update_attribute, so we know the overridden method
  # is being called
  def test_update_attribute_updates_cache
    map = TeamReviewResponseMap.create(
                             :reviewed_object_id => @assignment_id,
                             :reviewer_id => @existingParticipant_id,
                             :reviewee_id => @newTeam_id)
    response = Response.create(:map_id => map.id)

    question = Question.find_by_questionnaire_id(@reviewQuestionnaire_id)
    a = Score.create(:question_id=>question.id, :response_id => response.id,:score => 4)
    sc = ScoreCache.find(:first, :conditions => {:reviewee_id => @newTeam_id, :object_type => map.type})
    oldscore = sc.score
    a.update_attribute("score", 5)
    sc = ScoreCache.find(:first, :conditions => {:reviewee_id => @newTeam_id, :object_type => map.type})
    assert sc.score > oldscore
  end

  # test that update_cache is being called in Score.create, so we know the overridden method
  # is being called
  def test_create_updates_cache
    map = TeamReviewResponseMap.create(:reviewed_object_id => @assignment_id,
                             :reviewer_id => @existingParticipant_id,
                             :reviewee_id => @newTeam_id)
    map_type = map.type
    ScoreCache.destroy_all(:reviewee_id => @newTeam_id, :object_type=> map.type)
    oldcount = ScoreCache.count
    response = Response.create(:map_id => map.id)
    questions = Question.find_all_by_questionnaire_id(
         @reviewQuestionnaire_id )
    a = Score.create(:question_id=>questions.last, :response_id=>response.id,:score=> 3)
    assert ScoreCache.count == oldcount + 1
  end

  # Test whether the overridden Score.create creates scores. Also, verify that all
  # the information is retained because it seems strange no arguments are needed
  def test_create_creates_score

    map = TeamReviewResponseMap.create(:reviewed_object_id => @assignment_id,
                                  :reviewer_id => @existingParticipant_id,
                                  :reviewee_id => @newTeam_id)
    oldcount = Score.count
    response = Response.create(:map_id => map.id)
    questions = Question.find_all_by_questionnaire_id(
        @reviewQuestionnaire_id )
    a = Score.create(:question_id=>questions.last.id, :response_id=>response.id,:score=> 3)
    assert Score.count == oldcount + 1
    assert Score.find(a.id) == a
  end


  end