require "test/unit"
require File.dirname(__FILE__) + '/../test_helper'

class Assessment360Test < ActiveSupport::TestCase
  fixtures :assignments, :users, :roles, :participants, :courses

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @participant = Participant.find_all_by_user_id()
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  #
  def test_noOfReviewsByUser
     user = users(:student1)
     @participant = Participant.find_all_by_user_id(user)
     assert_not_nil @participant.count
     assert(@participant.count) == 2
  end

  def test_noOfmetareviewsByUser
     user = users(:student1)
     @participant = Participant.find_all_by_user_id(user)
     assert_not_nil @participant.count
     assert(@participant.count) == 0
  end
  
  def testAssignmentsExistsForCourse
     course = courses(:course_object_oriented)
     puts ("course=" , course.id) 
     @assignments = Assignment.find_all_by_course_id(course.id)
     puts @assignments.count
     if(@assignments.count)==0
       assert false
     else assert true
    end   
  end
  
  

end