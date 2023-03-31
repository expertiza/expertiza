require 'test_helper'

class GithubMetricUsesTest < ActiveSupport::TestCase
  test "initialize sets assignment_id" do
    assignment_id = 1
    github_use = GithubMetricUses.new(assignment_id)
    assert_equal assignment_id, github_use.instance_variable_get(:@assignment_id)
  end
end
