require File.dirname(__FILE__) + '/../test_helper'

class ResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :participants

  def setup
    @response_map = response_maps(:response_maps0)
  end
    
  def test_get_assessments_for
    @participant = participants(:par14)
    #debugger
    responses = FeedbackResponseMap.get_assessments_for(@participant)
    #print responses
    #assert_equal 1,responses.length
    #assert responses[0] == response_maps(:response_map7)
    assert_equal responses,@participant.get_feedback
    
  end

  def test_create_quiz_response_map
     response_map = ResponseMap.new
     response_map.reviewed_object_id = Fixtures.identify(:quiz_questionnaire2)
     response_map.reviewee_id = Fixtures.identify(:quiz_par2)
     response_map.reviewer_id = Fixtures.identify(:quiz_par3)
     response_map.type = "QuizResponseMap"
     assert response_map.save
  end

end
