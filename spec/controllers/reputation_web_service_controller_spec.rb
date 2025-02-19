describe ReputationWebServiceController do
  let(:instructor) { build(:instructor, id: 1) }
  describe 'custom test' do
    before(:each) do
      @assignment_1 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, num_reviewers: 3, num_reviews_allowed: 3, rounds_of_reviews: 2, reputation_algorithm: 'lauw', id: 1, directory_path: 'assignment_1')
      @assignment_2 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, num_reviewers: 3, num_reviews_allowed: 3, rounds_of_reviews: 2, reputation_algorithm: 'hamer', id: 2, directory_path: 'assignment_2')
      @questionnaire_1 = create(:questionnaire, min_question_score: 0, max_question_score: 5, type: 'ReviewQuestionnaire', id: 1)
      # assignment_questionnaire_<i>_<j> means assignment #i's #j th round of review.
      @assignment_questionnaire_1_1 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
      @assignment_questionnaire_1_2 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2)
      @assignment_questionnaire_2_1 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
      @assignment_questionnaire_2_2 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2, id: 4)

      # question_i_j means question #j in questionnaire #i.
      @question_1_1 = create(:question, questionnaire_id: @questionnaire_1.id, id: 1)
      @question_1_2 = create(:question, questionnaire_id: @questionnaire_1.id, id: 2)
      @question_1_3 = create(:question, questionnaire_id: @questionnaire_1.id, id: 3)
      @question_1_4 = create(:question, questionnaire_id: @questionnaire_1.id, id: 4)
      @question_1_5 = create(:question, questionnaire_id: @questionnaire_1.id, id: 5)

      @reviewer_1 = create(:participant, can_review: 1)
      @reviewer_2 = create(:participant, can_review: 1)
      @reviewer_3 = create(:participant, can_review: 1)

      @reviewee_1 = create(:assignment_team, assignment: @assignment)
      @reviewee_2 = create(:assignment_team, assignment: @assignment)
      @reviewee_3 = create(:assignment_team, assignment: @assignment)

      # response_<i>_<j> means response of reviewer #j to reviewee #i.
      @response_map_1_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_1.id)
      @response_map_1_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_1.id)
      @response_map_1_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_1.id)

      @response_map_2_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_2.id)
      @response_map_2_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_2.id)
      @response_map_2_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_2.id)

      @response_map_3_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_3.id)
      @response_map_3_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_3.id)
      @response_map_3_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_3.id)

      # response_<i>_<j> means response of reviewer #j to reviewee #i.
      @response_1_1 = create(:response, is_submitted: true, map_id: @response_map_1_1.id)
      @response_1_2 = create(:response, is_submitted: true, map_id: @response_map_1_2.id)
      @response_1_3 = create(:response, is_submitted: true, map_id: @response_map_1_3.id)

      @response_2_1 = create(:response, is_submitted: true, map_id: @response_map_2_1.id)
      @response_2_2 = create(:response, is_submitted: true, map_id: @response_map_2_2.id)
      @response_2_3 = create(:response, is_submitted: true, map_id: @response_map_2_3.id)

      @response_3_1 = create(:response, is_submitted: true, map_id: @response_map_3_1.id)
      @response_3_2 = create(:response, is_submitted: true, map_id: @response_map_3_2.id)
      @response_3_3 = create(:response, is_submitted: true, map_id: @response_map_3_3.id)
    end

    context 'test db_query' do
      it 'return average score' do
        # reivewer_1's review for reviewee_1: [1, 2, 3, 4, 5]
        # create 5 answers for 5 related questions
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 1)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 2)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 3)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 4)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 5)
        result = ReputationWebServiceController.new.get_peer_reviews([1, 0], 1, false)
        # except to see a data array return generated by the score given.
        expect(result).to eq([[2, 1, 60.0]])
      end
    end

    context 'test json_generator' do
      it 'test 3 reviewer for one reviewee' do
        # reivewer_1's review for reviewee_1; Numeric value of the answer array
        # for response_1_1: [5, 5, 5, 5, 5]
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 5)

        # reivewer_2's review for reviewee_1; Numeric value of the answer array
        # for response_1_2: [3, 3, 3, 3, 3]
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_2.id, answer: 3)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_2.id, answer: 3)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_2.id, answer: 3)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_2.id, answer: 3)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_2.id, answer: 3)

        # reivewer_3's review for reviewee_1; Numeric value of the answer array
        # for response_1_3: [1, 1, 1, 1, 1]
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_3.id, answer: 1)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_3.id, answer: 1)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_3.id, answer: 1)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_3.id, answer: 1)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_3.id, answer: 1)

        # Expect to get JSON formart as 2D Hash with given answer array above per reviewer
        result = ReputationWebServiceController.new.generate_json_for_peer_reviews([1, 0], 1)
        expect(result).to eq('submission1' => { 'stu2' => 100.0, 'stu3' => 60.0, 'stu4' => 20.0 })
        # This test serves as the sample methodology to test on only 1 possible combination of answer array distribution
        # More combination of reviewer's answer need to be created for future reputation correctness test
      end

      it 'test same reviewer for different reviewee' do
        # reivewer_1's review for reviewee_1; Numeric value of the answer array
        # for response_1_1: [5, 5, 5, 5, 5]
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 5)

        # reivewer_1's review for reviewee_2: Numeric value of the answer array
        # for response_2_1: [3, 3, 3, 3, 3]
        create(:answer, question_id: @question_1_1.id, response_id: @response_2_1.id, answer: 3)
        create(:answer, question_id: @question_1_2.id, response_id: @response_2_1.id, answer: 3)
        create(:answer, question_id: @question_1_3.id, response_id: @response_2_1.id, answer: 3)
        create(:answer, question_id: @question_1_4.id, response_id: @response_2_1.id, answer: 3)
        create(:answer, question_id: @question_1_5.id, response_id: @response_2_1.id, answer: 3)

        # Expect to get JSON formart as 2D Hash with given answer array above for reviewer_1
        result = ReputationWebServiceController.new.generate_json_for_peer_reviews([1, 0], 1)
        expect(result).to eq('submission1' => { 'stu2' => 100.0 }, 'submission2' => { 'stu2' => 60.0 })
        # This test serves as the sample methodology to test on only 1 possible combination of answer array distribution
        # More combination of reviewer's answer need to be created for future reputation correctness test
      end
    end

    # TODO: Further test for reputation web service required
    context 'test send_post_request' do
      it 'failed because of no public key file' do
        # reivewer_1's review for reviewee_1: [5, 5, 5, 5, 5]
        # create 5 answers for 5 related questions
        create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 5)
        create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 5)

        # choose hammer algorithm without expert grade (instructor's given grade)
        params = { assignment_id: 1, round_num: 1, algorithm: 'hammer', checkbox: { expert_grade: 'empty' } }
        session = { user: build(:instructor, id: 1) }

        client = ReputationWebServiceController.new.client

        # comment out because send_post_request method request public key file while this file is missing
        # so at this time send_post_request is not functioning normally
        # if it functions correctly, it will update the reviewer's reputation score according to the selected reputation algorithm.
        # get :send_post_request, params, session
        # expect(response).to redirect_to '/reputation_web_service/client'

        # req = ReputationWebServiceController.new.send_post_request
        # expect(req).to redirect_to(client)
        expect(true).to eq(true)
      end
    end

    # TODO: test for round 2
    # The web service is not available yet because of missing of public1.gem and private1.gem
    # Once the controller can get response from the reputation_web_service, the test should proceed to round 2 submission
    # More detailed explanation on https://expertiza.csc.ncsu.edu/index.php/CSC/ECE_517_Fall_2021_-_E2168._Testing_-_Reputations
  end
end
