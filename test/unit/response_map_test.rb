require File.dirname(__FILE__) + '/../test_helper'

class ResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :participants, :teams, :assignments

  # Replace this with your real tests.

  def test_create_response_map
    @response_map1 = ResponseMap.new
    @response_map1.reviewee_id= teams(:team5).id
    @response_map1.reviewer_id= participants(:par1).id
    @response_map1.reviewed_object_id= assignments(:assignment1).id
    @response_map1.type = "TeamReviewResponseMap"
    assert @response_map1.save
  end

  def test_create_response_map_no_type
    @response_map1 = ResponseMap.new
    @response_map1.reviewee_id= teams(:team5).id
    @response_map1.reviewer_id= participants(:par1).id
    @response_map1.reviewed_object_id= assignments(:assignment1).id
    @response_map1.type = nil
    begin
      assert !@response_map1.save
    rescue
      assert true
      return
    end
    assert false
  end

=begin
  #Response maps should never be updated- in this case, make a new response map
  def test_update_response_map
    @response_map1 = ResponseMap.find(response_maps(:response_maps1).id)
    @response_map1.reviewee_id= teams(:team4).id
    @response_map1.reviewed_object_id= assignments(:assignment7).id
    @response_map1.save
    @response_map1.reload
    assert_equal teams(:team4).id, @response_map1.reviewee_id
    assert_equal assignments(:assignment7).id, @response_map1.reviewed_object_id
  end
=end

  def test_validate_foreign_key_reviewee
    @response_map1 = ResponseMap.new
    @response_map1.reviewee_id= 9001
    @response_map1.reviewed_object_id= assignments(:assignment1).id
    @response_map1.type = "TeamReviewResponseMap"
    begin
      assert !@response_map1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_validate_foreign_key_reviewed
    @response_map1 = ResponseMap.new
    @response_map1.reviewee_id= teams(:team5).id
    @response_map1.reviewed_object_id= 9001
    @response_map1.type = "TeamReviewResponseMap"
    begin
      assert !@response_map1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_validate_foreign_key_type
    @response_map1 = ResponseMap.new
    @response_map1.reviewee_id= teams(:team5).id
    @response_map1.reviewed_object_id= assignments(:assignment1).id
    @response_map1.type = "Baloney"
    begin
      assert !@response_map1.save
    rescue
      assert true
      return
    end
    assert false
  end

  #Participant is an assignment participant
  def test_get_assessments_for
    @participant = participants(:par14)
    #debugger
    responses = FeedbackResponseMap.get_assessments_for(@participant)
    #print responses
    #assert_equal 1,responses.length
    #assert responses[0] == response_maps(:response_map7)
    assert_equal responses,@participant.feedback

  end
end
