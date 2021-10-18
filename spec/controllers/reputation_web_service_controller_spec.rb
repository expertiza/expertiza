describe ReputationWebServiceController do
  let(:instructor){build(:instructor, id:1)}

  describe '' do
    before(:each) do
      @assignment_1 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, rounds_of_reviews: 2, reputation_algorithm: 'lauw', id: 1)
      @assignment_2 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, rounds_of_reviews: 2, reputation_algorithm: 'hamer', id: 2)
      @questionnaire_1 = create(:questionnaire, min_question_score: 0, max_question_score: 5, default_num_choices: 1, type: 'ReviewQuestionnaire', id: 1)
      @questionnaire_2 = create(:questionnaire, min_question_score: 0, max_question_score: 5, default_num_choices: 1, type: 'ReviewQuestionnaire', id: 2)
      @assignment_questionnaire_1_1 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1, id: 1)
      @assignment_questionnaire_1_2 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_2.id, used_in_round: 2, id: 2)
      @assignment_questionnaire_2_1 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1, id: 3)
      @assignment_questionnaire_2_2 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_2.id, used_in_round: 2, id: 4)

      @question_1_1 = create(:question, questionnaire_id: @questionnaire_1.id, id: 1)
      @question_1_2 = create(:question, questionnaire_id: @questionnaire_1.id, id: 2)
      @question_1_3 = create(:question, questionnaire_id: @questionnaire_1.id, id: 3)
      @question_1_4 = create(:question, questionnaire_id: @questionnaire_1.id, id: 4)
      @question_1_5 = create(:question, questionnaire_id: @questionnaire_1.id, id: 5)
      @question_1_1 = create(:question, questionnaire_id: @questionnaire_2.id, id: 6)
      @question_1_2 = create(:question, questionnaire_id: @questionnaire_2.id, id: 7)
      @question_1_3 = create(:question, questionnaire_id: @questionnaire_2.id, id: 8)
      @question_1_4 = create(:question, questionnaire_id: @questionnaire_2.id, id: 9)
      @question_1_5 = create(:question, questionnaire_id: @questionnaire_2.id, id: 10)

      @reviewer_1 = create(:participant, can_review: 1)
      @reviewer_2 = create(:participant, can_review: 1)
      @reviewer_3 = create(:participant, can_review: 1)
      @reviewer_4 = create(:participant, can_review: 1)
      @reviewer_5 = create(:participant, can_review: 1)

      @reviewee_1 = create(:assignment_team, assignment: @assignment)
      @reviewee_2 = create(:assignment_team, assignment: @assignment)
      @reviewee_3 = create(:assignment_team, assignment: @assignment)

      @response_map_1_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_1.id)
      @response_map_1_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_1.id)
      @response_map_1_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_1.id)
      @response_map_1_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_1.id)
      @response_map_1_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_1.id)
      @response_map_2_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_2.id)
      @response_map_2_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_2.id)
      @response_map_2_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_2.id)
      @response_map_2_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_2.id)
      @response_map_2_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_2.id)
      @response_map_3_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_3.id)
      @response_map_3_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_3.id)
      @response_map_3_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_3.id)
      @response_map_3_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_3.id)
      @response_map_3_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_3.id)

      @response_1_1 = create(:response, is_submitted: true, map_id: @response_map_1_1.id)
      @response_1_2 = create(:response, is_submitted: true, map_id: @response_map_1_2.id)
      @response_1_3 = create(:response, is_submitted: true, map_id: @response_map_1_3.id)
      @response_1_4 = create(:response, is_submitted: true, map_id: @response_map_1_4.id)
      @response_1_5 = create(:response, is_submitted: true, map_id: @response_map_1_5.id)
      @response_2_1 = create(:response, is_submitted: true, map_id: @response_map_2_1.id)
      @response_2_2 = create(:response, is_submitted: true, map_id: @response_map_2_2.id)
      @response_2_3 = create(:response, is_submitted: true, map_id: @response_map_2_3.id)
      @response_2_4 = create(:response, is_submitted: true, map_id: @response_map_2_4.id)
      @response_2_5 = create(:response, is_submitted: true, map_id: @response_map_2_5.id)
      @response_3_1 = create(:response, is_submitted: true, map_id: @response_map_3_1.id)
      @response_3_2 = create(:response, is_submitted: true, map_id: @response_map_3_2.id)
      @response_3_3 = create(:response, is_submitted: true, map_id: @response_map_3_3.id)
      @response_3_4 = create(:response, is_submitted: true, map_id: @response_map_3_4.id)
      @response_3_5 = create(:response, is_submitted: true, map_id: @response_map_3_5.id)
    end

    it '' do
       create(:answer, question_id: @question_1_1, response_id: @response_1_1, answer: 5)
       #repeat for different answers
    end
  end

end
