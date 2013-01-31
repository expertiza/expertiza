require File.dirname(__FILE__) + '/../test_helper'

class ReviewResponseMapTest < ActiveSupport::TestCase
  fixtures :response_maps, :questionnaires , :assignments, :responses #include the two fixtures
  test "questionnaire_title" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment0)
    responses = ReviewResponseMap.new
    assert_equal responses.get_title, "Review"
  end

  test "method_questionnaire" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment0)
    reviewrespmap = ReviewResponseMap.new
    reviewrespmap.assignment = @assignment
    reviewrespmap.questionnaire
    assert_equal reviewrespmap.assignment.questionnaires[0].type, "ReviewQuestionnaire"
  end

  test "method_delete_review_response_map" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment0)
    reviewrespmap = ReviewResponseMap.new
    reviewrespmap.assignment = @assignment
    reviewrespmap.response = nil
    assert_equal  reviewrespmap.delete(1), reviewrespmap
  end

  test "method_delete_review_response_map_not_with_force" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment0)
    reviewrespmap = ReviewResponseMap.new
    reviewrespmap.assignment = @assignment
    reviewrespmap.response = nil
    assert_equal  reviewrespmap.delete(), reviewrespmap
  end

  test "method_get_export_fields" do
    fields_1 = ["contributor","reviewed by"]
    fields_2 = ReviewResponseMap.get_export_fields(1)
    assert_equal fields_2[0], fields_1[0]
    assert_equal fields_2[1], fields_1[1]
  end

  test "method_get_import_fields" do
    p = ReviewResponseMap.import(['student2','student2'], 2, "827400667")
    assert_equal p , nil
  end

  test "method_get_import_raise_less_than_two_items" do
    assert_raise (ArgumentError) {ReviewResponseMap.import([''], 2, "827400667")}
  end

  test "method_get_import_with_incorrect_assignment_id" do
    @assignment = '123'
    assert_raise (ActiveRecord::RecordNotFound) {ReviewResponseMap.import(['student2','student2'], 2, @assignment)}
  end

  test "method_get_import_with_incorrect_user" do
    @user1 = 'student30'
    @user = 'student20'
    assert_raise (ImportError) {ReviewResponseMap.import([@user1,@user,'student2'], 2, "827400667")}
  end

  test "method_get_import_with_incorrect_reviewer" do
    @user = 'abc'
    assert_raise (ImportError) {ReviewResponseMap.import(['student2',@user], 2, "827400667")}
  end

  test "method_get_import_team_assignment_with_no_reviewee" do
    @assignment = assignments(:assignment2)
    @assignment.team_assignment= true
    assert_raise (ImportError) {ReviewResponseMap.import(['student1','student2'], 2, @assignment)}
  end

  test "method_show_feedback" do
    @questionnaire = questionnaires(:questionnaire0)
    @assignment = assignments(:assignment0)
    rev = ReviewResponseMap.new
    rev.assignment = @assignment
    rev.response =  responses(:response0)
    rev.show_feedback
  end

  test "method_add_reviewer" do
        p = ReviewResponseMap.add_reviewer(299716733,148111809,108022375)
        assert p.save
  end

  #test "method_add_reviewer_already_existing_Fails" do
  #      p = ReviewResponseMap.add_reviewer(217499789,311582000,20698453)
  #      assert p.invalid?
  #end
  test "method_delete_review_response_map_exception" do
    @assignment = assignments(:assignment0)
    reviewrespmap = ReviewResponseMap.new
    reviewrespmap.response = responses(:response0)
    reviewrespmap.assignment = @assignment
    assert_raise (LocalJumpError, reviewrespmap.delete(0))
  end


end
