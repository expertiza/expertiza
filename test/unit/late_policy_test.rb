require File.dirname(__FILE__) + '/../test_helper'

class LatePolicyTest < ActiveSupport::TestCase
  fixtures :late_policies, :participants, :deadline_types, :users

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_invalid_with_empty_attributes
    # Create a new late policy
    late_policy = LatePolicy.new
    # Assignment should not be valid, because some fields have not been created.
    assert !late_policy.valid?
    # times_used is initialized to 0 by the controller.
    assert_equal late_policy.times_used, 0
  end

  def test_add_late_policy
    late_policy = LatePolicy.new
    late_policy.policy_name = "Default pol"
    late_policy.max_penalty = 10
    late_policy.penalty_per_unit = 1
    late_policy.instructor_id =  User.find(users(:instructor1).id).id
    late_policy.save! # an exception is thrown if the late_policy is invalid
  end

  #add policy
  def test_add_policy_with_invalid_policy_name
    late_policy = LatePolicy.new
    late_policy.policy_name = " Default pol."
    late_policy.max_penalty = 10
    late_policy.penalty_per_unit = 1
    late_policy.instructor_id =  User.find(users(:instructor1).id).id
    assert !late_policy.valid?
  end

  def test_add_policy_with_invalid_penalty_per_unit
    late_policy = LatePolicy.new
    late_policy.policy_name = "Default pol."
    late_policy.max_penalty = 10
    late_policy.penalty_per_unit = -1
    late_policy.instructor_id =  User.find(users(:instructor1).id).id
    assert !late_policy.valid?
  end

  def test_add_policy_with_invalid_max_penalty
    late_policy = LatePolicy.new
    late_policy.policy_name = "Default pol."
    late_policy.max_penalty = 0
    late_policy.penalty_per_unit = 1
    late_policy.instructor_id =  User.find(users(:instructor1).id).id
    assert !late_policy.valid?
  end

  #update policy
  def test_update_policy_with_valid_policy_name
    @late_policy = LatePolicy.find(late_policies(:late_policy3).id)
    @late_policy.policy_name = "new name"

    @late_policy.save
    @late_policy.reload

    assert_equal "new name", @late_policy.policy_name
  end

  def test_update_policy_with_invalid_policy_name
    @late_policy = LatePolicy.find(late_policies(:late_policy3).id)
    @late_policy.policy_name = " new name"

    assert !@late_policy.save

  end

  def test_update_policy_with_invalid_penalty_per_unit
    @late_policy = LatePolicy.find(late_policies(:late_policy3).id)
    @late_policy.penalty_per_unit = 0

    assert !@late_policy.save
  end

  def test_update_policy_with_invalid_max_penalty
    @late_policy = LatePolicy.find(late_policies(:late_policy3).id)
    @late_policy.max_penalty = -1

    assert !@late_policy.save
  end
end
