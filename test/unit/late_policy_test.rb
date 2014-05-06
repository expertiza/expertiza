require File.dirname(__FILE__) + '/../test_helper'

class LatePolicyTest < ActiveSupport::TestCase
  fixtures :late_policies, :users

  # Replace this with your real tests.
  def test_create_late_policy
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    #@late_policy1.policy_name= teams(:team5).id
    assert @late_policy1.save
  end

  def test_create_late_policy_no_name
    @late_policy1 = LatePolicy.new
    #@late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_no_instructor
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    #@late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_no_max_penalty
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    #@late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_low_max_penalty
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 0
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_high_max_penalty
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 50
    @late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_no_penalty_per_unit
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    #@late_policy1.penalty_per_unit = 5
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_low_penalty_per_unit
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = -1
    @late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end

  def test_create_late_policy_no_penalty_unit
    @late_policy1 = LatePolicy.new
    @late_policy1.policy_name = "Overdue"
    @late_policy1.instructor_id = users(:instructor1).id
    @late_policy1.max_penalty = 30
    @late_policy1.penalty_per_unit = 5
    #@late_policy1.penalty_unit = "day"
    begin
      assert @late_policy1.save
    rescue
      assert true
      return
    end
    assert false
  end
end
