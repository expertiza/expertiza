require 'test_helper'

class SelfReviewResponseMapTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :questionnaires, :assignments, :assignment_questionnaires, :participants, :responses, :teams, :response_maps, :teams_users

  test "method_questionnaire" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment1)
    reviewrespmap = SelfReviewResponseMap.new
    reviewrespmap.assignment = @assignment
    reviewrespmap.questionnaire 1
    assert_equal reviewrespmap.assignment.questionnaires[0].type, "ReviewQuestionnaire"
  end

  test "method_get_title" do
    p = SelfReviewResponseMap.new
    assert_equal p.get_title, "Self Review"
  end

  test "method_contributor" do
    p = SelfReviewResponseMap.new
    p.reviewee = teams(:team0)
    team_id = p.contributor
    assert_equal p.reviewee.id, team_id.id
  end

  test "reviewer_reviewee_same_team_test" do
    p = SelfReviewResponseMap.new
    p.reviewee = teams(:team0)
    @participant = participants(:par1)
    team_id = TeamsUser.find_by_sql(["SELECT t.id as t_id FROM teams_users u, teams t WHERE u.team_id = t.id and t.parent_id = ? and user_id = ?", @participant.parent_id, @participant.user_id])
    assert_equal p.reviewee.id, team_id[0].t_id
  end


end
