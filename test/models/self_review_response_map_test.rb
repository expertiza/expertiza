require 'test_helper'

class SelfReviewResponseMapTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :questionnaires, :assignments

  # Replace this with your real tests.

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
end
