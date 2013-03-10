require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :nodes

  def setup
    @course_node = nodes(:node23)
  end

  def test_get_children
    assert(@course_node.get_children('name', 'ASC', 'admin', true) != nil, 'Should be true')
  end

  def test_get_name
    assert_equal("CSC110", @course_node.get_name)
  end

  def test_get_directory
    assert_equal("csc110", @course_node.get_directory)
  end

  def test_get_creation_date
    assert(@course_node.get_creation_date != nil, 'Should be true')
  end

  def test_get_modified_date
    assert(@course_node.get_modified_date != nil, 'Should be true')
  end

  def test_get_teams
    assert(@course_node.get_teams != nil, 'Should be true')
  end

end
