require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :courses, :users, :nodes, :assignments

  def setup
    @course = courses(:course1)
    @user = users(:admin)
  end

  def test_get_children
    cnode = CourseNode.new
    cnode.get_children('name', 'ASC', 'admin', true)

    assert true
  end

  def test_get_name
    cnode = CourseNode.new
    assert(cnode.get_name != '', 'Should be true')
  end

  def test_get_directory
    cnode = CourseNode.new
    assert(cnode.get_directory != '', 'Should be true')
  end

  def test_get_creation_date
    cnode = CourseNode.new
    assert(cnode.get_creation_date != '', 'Should be true')
  end

  def test_get_modified_date
    cnode = CourseNode.new
    assert(cnode.get_modified_date != '', 'Should be true')
  end

  def test_get_teams
    cnode = CourseNode.new
    assert(cnode.get_teams != nil, 'Should be true')
  end

  def test_get_survey_distribution_id
    cnode = CourseNode.new
    assert(cnode.get_survey_distribution_id != nil, 'Should be true')
  end

  def test_get_creation_date
    cnode = CourseNode.new
    assert(cnode.get_survey_distribution_id != nil, 'Should be true')
  end

end
