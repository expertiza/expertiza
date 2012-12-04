require File.dirname(__FILE__) + '/../test_helper'
# Testing for score_cache

class ScoreCacheTest < ActiveSupport::TestCase
  fixtures :assignments, :assignment_questionnaires, :teams_users, :responses, :questions, :response_maps, :scores, :questionnaires, :score_caches, :teams

  # This test updates the ScoreCache when a reviewer changes his score for a review-response.
  #Assert1: Checks if a record with the required specifications already exists.
  #Assert2: Checks if the existing record has been updated with the expected value.
  def test_update_cache_update_record
    response = responses(:response0)
    expected_contributor = teams(:team3)

    sc_old = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  expected_contributor.id, 'TeamReviewResponseMap' ])
    assert_not_nil(sc_old, "This is not the case of update")

    ScoreCache.update_cache(response.id)
    sc_new = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  expected_contributor.id, 'TeamReviewResponseMap' ])
    assert_equal(sc_new.score, 83.33,"The score was not saved into score_cache table correctly")
  end

  # This test creates a new entry in the ScoreCache when a reviewer submits a review-response.
  #Assert1: Checks if a record with the required specifications dose not already exist.
  #Assert2: Checks if a new record has been created with the expected value.
  def test_update_cache_new_record
    response = responses(:response8)
    expected_contributor = teams(:team6)

    sc_old =  ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  expected_contributor.id, 'TeamReviewResponseMap' ])
    assert_nil(sc_old, "The data is already present in the database, is is not the case of inserting a new record into score cache")

    ScoreCache.update_cache(response.id)
    sc_new = ScoreCache.find(:first,:conditions =>["reviewee_id = ? and object_type = ?",  expected_contributor.id, 'TeamReviewResponseMap' ])
    assert_equal(sc_new.score, 71.67,"The score was not saved into the score_cache table correctly")
  end

  def test_compute_scoreset_review
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    scoreParameter = "review"
    score_stat = ScoreCache.compute_scoreset(allscores , scoreParameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_stat, "The score_stat is not assigned correctly" )
  end

  def test_compute_scoreset_teammate
    allscores = Hash.new
    allscores[:teammate] = Hash.new
    allscores[:teammate][:scores] = Hash.new
    allscores[:teammate][:scores][:avg] = 80
    allscores[:teammate][:scores][:min] = 60
    allscores[:teammate][:scores][:max] = 100
    score_parameter = "teammate"
    score_stat = ScoreCache.compute_scoreset(allscores , score_parameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_stat, "The score_stat is not assigned correctly" )
  end

  def test_compute_scoreset_metareview
    allscores = Hash.new
    allscores[:metareview] = Hash.new
    allscores[:metareview][:scores] = Hash.new
    allscores[:metareview][:scores][:avg] = 80
    allscores[:metareview][:scores][:min] = 60
    allscores[:metareview][:scores][:max] = 100
    score_parameter = "metareview"
    score_stat = ScoreCache.compute_scoreset(allscores , score_parameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_stat, "The score_stat is not assigned correctly" )
  end

  def test_compute_scoreset_feedback
    allscores = Hash.new
    allscores[:feedback] = Hash.new
    allscores[:feedback][:scores] = Hash.new
    allscores[:feedback][:scores][:avg] = 80
    allscores[:feedback][:scores][:min] = 60
    allscores[:feedback][:scores][:max] = 100
    score_parameter = "feedback"
    score_stat = ScoreCache.compute_scoreset(allscores , score_parameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_stat, "The score_stat is not assigned correctly" )
  end

  def test_compute_scoreset_nil_allscores
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = nil
    allscores[:review][:scores][:min] = nil
    allscores[:review][:scores][:max] = nil
    score_parameter = "review"
    score_stat = ScoreCache.compute_scoreset(allscores , score_parameter)
    score_expected = {:min =>nil, :max =>nil, :avg => nil}
    assert_equal(score_expected, score_stat, "The score_stat is not assigned nil" )
  end

  def test_compute_scoreset_nil_scoreparameter
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_stat = ScoreCache.compute_scoreset(allscores ,nil)
    score_expected = Hash.new
    score_expected[:min] = nil
    score_expected[:avg] = nil
    score_expected[:max] = nil
    assert_equal(score_expected, score_stat, "The scoreparameter is not specified " )
  end

  def test_get_my_scores_teamreview
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = "TeamReviewResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_set, "The score_set is not assigned correctly" )
  end

  def test_get_my_scores_participantreview
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = "ParticipantReviewResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    score_expected = {:min =>60.0, :max =>100.0, :avg => 80.0}
    assert_equal(score_expected, score_set, "The score_set is not assigned correctly" )
  end

  def test_get_my_scores_teammatereview
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = "TeammateReviewResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    score_expected = {:min => nil, :max => nil, :avg => nil}
    assert_equal(score_expected, score_set, "The score_set is not assigned correctly" )
  end

  def test_get_my_scores_metareview
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = "MetareviewResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    score_expected = {:min => nil, :max => nil, :avg => nil}
    assert_equal(score_expected, score_set, "The score_set is not assigned correctly" )
  end

  def test_get_my_scores_feedback
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = "FeedbackResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    score_expected = {:min => nil, :max => nil, :avg => nil}
    assert_equal(score_expected, score_set, "The score_set is not assigned correctly" )
  end

  def test_get_my_scores_teamreview_nil_scoreparameter
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = 80
    allscores[:review][:scores][:min] = 60
    allscores[:review][:scores][:max] = 100
    score_parameter = nil
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    #score_expected = nil
    assert_not_nil(score_set, "The score_set is not assigned correctly when score parameter is nil" )
  end

  def test_get_my_scores_teamreview_nil_allscores
    allscores = Hash.new
    allscores[:review] = Hash.new
    allscores[:review][:scores] = Hash.new
    allscores[:review][:scores][:avg] = nil
    allscores[:review][:scores][:min] = nil
    allscores[:review][:scores][:max] = nil
    score_parameter = "TeammateReviewResponseMap"
    score_set = ScoreCache.get_score_set_for_review_type(allscores , score_parameter)
    #score_expected = nil
    assert_not_nil(score_set, "The score_set is not assigned correctly when score parameter is nil" )
    end
end

