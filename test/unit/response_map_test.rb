require File.dirname(__FILE__) + '/../test_helper'

class ResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :participants

  # Replace this with your real tests.
    
  def test_get_assessments_for
    @participant = participants(:par14)
    #debugger
    responses = FeedbackResponseMap.get_assessments_for(@participant)
    #print responses
    #assert_equal 1,responses.length
    #assert responses[0] == response_maps(:response_map7)
    assert_equal responses,@participant.get_feedback
    
  end
end
