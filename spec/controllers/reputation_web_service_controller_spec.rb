describe ReputationWebServiceController do
  let(:team){build(:assignment_team, id:1)}
  describe '' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, rounds_of_reviews: 2, reputation_algorithm: 'lauw')
      @questionnaire = create(:questionnaire, min_question_score: 0, max_question_score: 10, default_num_choices: 1, type: 'ReviewQuestionnaire')
      @assignment_questionnaire_1 = create(:assignment_questionnaire, assignment_id: @assignment.id, questionnaire_id: @questionnaire.id, used_in_round: 1)
      @assignment_questionnaire_2 = create(:assignment_questionnaire, assignment_id: @assignment.id, questionnaire_id: @questionnaire.id, used_in_round: 2)

      @reviewer_1 = create(:participant, can_review: 1)
      @reviewer_2 = create(:participant, can_review: 1)
      @reviewer_3 = create(:participant, can_review: 1)
      @reviewer_4 = create(:participant, can_review: 1)
      @reviewer_5 = create(:participant, can_review: 1)

      @reviewee = create(:assignment_team, assignment: @assignment)

      @response_map_1 = create(:review_response_map, reviewer: @reviewer_1)
      @response_map_2 = create(:review_response_map, reviewer: @reviewer_2)
      @response_map_3 = create(:review_response_map, reviewer: @reviewer_3)
      @response_map_4 = create(:review_response_map, reviewer: @reviewer_4)
      @response_map_5 = create(:review_response_map, reviewer: @reviewer_5)

    end

    it '' do
      # create()
    end
  end
end
