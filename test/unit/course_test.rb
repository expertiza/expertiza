require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :courses,:teams,:users,:participants,:assignments,:nodes,:tree_folders, :roles

  def setup
    @course = courses(:course1)
    @course0 = courses(:course0)
  end
  
  def test_retrieval
    assert_kind_of Course, @course
    assert_equal "CSC111", @course.name
    assert_equal courses(:course1).id, @course.id 
    assert_equal courses(:course1).instructor_id, @course.instructor_id
    assert_equal 'csc111', @course.directory_path
    assert_equal 'CSC111 Programming Class', @course.info
    assert @course.private
  end
 
  def test_update
    assert_equal "CSC111", @course.name
    @course.name = "Object-Oriented"
    @course.save
    @course.reload
    assert_equal "Object-Oriented", @course.name
  end
  
  def test_destroy
    @course.destroy
    assert_raise(ActiveRecord::RecordNotFound){ Course.find(@course.id) }
  end

# test method get_teams
  def test_get_teams
    @teams = @course0.get_teams
    assert_equal 2,@teams.count
    assert_equal 'team3', @teams.first.name
    assert_equal 'team8', @teams.last.name
  end

  # test method get_path
  def test_get_path
    assert_equal RAILS_ROOT + '/pg_data/instructor3/csc110/',@course0.get_path
  end

  # test method get_participants
  def test_get_participants
    @participants = @course0.get_participants
    assert_equal 4, @participants.count
  end

  # test method get_participant
  def test_get_participant
    @participant = @course0.get_participant(users(:student6).id)
    assert_equal 'student6',@participant.first.name
  end

  # test method add_participant
  def test_add_participant
    assert_difference('@course0.get_participants.count') do
      @course0.add_participant(users(:ta1).name)
    end

    assert_difference('@course0.get_participants.count',0) do
      @course0.add_participant(users(:student6).name)
    end
  end

  # test method copy_participants
  def test_copy_participants
    assert_difference('@course0.get_participants.count', +3) do
      @course0.copy_participants(assignments(:assignment2).id)
    end
  end
end
