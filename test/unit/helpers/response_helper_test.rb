#require 'test/unit'
require 'test_helper'

class ResponseHelperTest < ActionView::TestCase

  fixtures :assignments, :response_maps, :questions
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    fail('Not implemented')
  end

  def test_check_threshold
    @assignment = Assignment.find(assignments(:assignment7))
    @assignment.review_topic_threshold = 15
    @map = ResponseMap.find(response_maps(:response_maps4))
    assert_equal(true,check_threshold)
  end

  def test_find_number_of_responses
    question=Question.find(questions(:question3))
    @map=ResponseMap.find(response_maps(:response_maps0))
    assert (find_number_of_responses(question)==0)
  end
end