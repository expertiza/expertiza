# frozen_string_literal: true
require 'test_helper'

class GithubMetricUsesControllerTest < ActionController::TestCase

  test "should save new assignment_id if not exist" do
    assignment_id = 1
    assert_nil GithubMetricUses.find_by(assignment_id: assignment_id)
    post :save, params: { assignment_id: assignment_id }
    assert_response :success
    assert_not_nil GithubMetricUses.find_by(assignment_id: assignment_id)
  end

  test "should not save existing assignment_id" do
    assignment_id = 1
    github_use = GithubMetricUses.new(assignment_id: assignment_id)
    github_use.save
    assert_not_nil GithubMetricUses.find_by(assignment_id: assignment_id)
    post :save, params: { assignment_id: assignment_id }
    assert_response :success
    assert_equal 1, GithubMetricUses.where(assignment_id: assignment_id).size
  end

  test "should delete existing assignment_id" do
    assignment_id = 1
    github_use = GithubMetricUses.new(assignment_id: assignment_id)
    github_use.save
    assert_not_nil GithubMetricUses.find_by(assignment_id: assignment_id)
    post :delete, params: { assignment_id: assignment_id }
    assert_response :success
    assert_nil GithubMetricUses.find_by(assignment_id: assignment_id)
  end

  test "should not delete non-existent assignment_id" do
    assignment_id = 1
    assert_nil GithubMetricUses.find_by(assignment_id: assignment_id)
    post :delete, params: { assignment_id: assignment_id }
    assert_response :success
    assert_nil GithubMetricUses.find_by(assignment_id: assignment_id)
  end

end


