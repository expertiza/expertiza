require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles
  
  # Test user retrieval by email
  def test_get_parents_includes_self
    roles = Role.all
    roles.each do |role|
      assert role.get_parents.include? role
    end
  end

  def test_get_parents_includes_children
    student = roles(:Student_role)
    ta = roles(:Teaching_Assistant_role)
    instructor = roles(:Instructor_role)

    # confirm test assumptions
    assert_equal student, ta.parent
    assert_equal ta, instructor.parent

    assert instructor.get_parents.include? ta
    assert instructor.get_parents.include? student
    assert ta.get_parents.include? student
  end

end
