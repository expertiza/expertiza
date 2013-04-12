require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :nodes, :users, :roles

  def setup
    @course_node = nodes(:node23)
  end

  def test_get_children_with_show_true_and_non_TA_and_ascending_order_by_name
    @results = @course_node.get_children('name', 'ASC', User.find_by_login('instructor3'), true)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_true_and_non_TA_and_descending_order_by_name
    @results = @course_node.get_children('name', 'DESC', User.find_by_login('instructor3'), true)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_true_and_TA_and_ascending_order_by_name
    @results = @course_node.get_children('name', 'ASC', User.find_by_login('ta1'), true)
    assert(@results != nil, 'Should be true')
    assert_equal(0, @results.count)
  end

  def test_get_children_with_show_true_and_TA_and_descending_order_by_name
    @results = @course_node.get_children('name', 'DESC', User.find_by_login('ta1'), true)
    assert(@results != nil, 'Should be true')
    assert_equal(0, @results.count)
  end

  def test_get_children_with_show_false_and_non_TA_and_ascending_order_by_name
    @results = @course_node.get_children('name', 'ASC', User.find_by_login('instructor3'), false)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_false_and_non_TA_and_descending_order_by_name
    @results = @course_node.get_children('name', 'DESC', User.find_by_login('instructor3'), false)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_false_and_TA_and_ascending_order_by_name
    @results = @course_node.get_children('name', 'ASC', User.find_by_login('ta1'), false)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_false_and_TA_and_descending_order_by_name
    @results = @course_node.get_children('name', 'DESC', User.find_by_login('ta1'), false)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
  end

  def test_get_children_with_show_false_and_non_TA_and_nil_order_by_nil
    @results = @course_node.get_children(nil, nil, User.find_by_login('instructor3'), false)
    assert(@results != nil, 'Should be true')
    assert_equal(1, @results.count)
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

  def test_get_parent_id
    assert_equal nodes(:node_courses).id,CourseNode.get_parent_id
  end

end
