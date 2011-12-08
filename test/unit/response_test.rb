require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < ActiveSupport::TestCase
  fixtures :responses

  def setup
    @response = responses(:response0)
  end

  def test_create_quiz_response
    response = Response.new
    response.map_id = Fixtures.identify(:quiz_response_map)
    response.additional_comment = "quiz response"
    assert response.save
  end

  def test_update_quiz_response
    response = Response.find(Fixtures.identify(:quiz_response))
    assert_equal "quiz response", response.additional_comment
    response.additional_comment = "updated quiz response"
    response.save
    response.reload
    assert_equal "updated quiz response", response.additional_comment
  end

  def test_destroy_quiz_response
    response = Response.find(Fixtures.identify(:quiz_response))
    response.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Response.find(response.id) }
  end

end
