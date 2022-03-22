describe ReputationWebServiceController do
    let(:instructor) { build(:instructor, id: 1) }
    describe 'custom test' do
      before(:each) do
        # @assignment_1 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, num_reviewers: 3, num_reviews_allowed: 3, rounds_of_reviews: 2, reputation_algorithm: 'lauw', id: 1, directory_path: 'assignment_1')
        @assignment_1 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, num_reviewers: 3, num_reviews_allowed: 3, rounds_of_reviews: 2, reputation_algorithm: 'hamer', id: 2, directory_path: 'assignment_1')
        @questionnaire_1 = create(:questionnaire, min_question_score: 0, max_question_score: 5, type: 'ReviewQuestionnaire', id: 1)

        # assignment_questionnaire_<i>_<j> means assignment #i's #j th round of review.
        @assignment_questionnaire_1_1 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
        @assignment_questionnaire_1_2 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2)
        # @assignment_questionnaire_2_1 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
        # @assignment_questionnaire_2_2 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2, id: 4)
  
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
  
      # TODO: Further test for reputation web service required
      context 'test send_post_request' do
        it 'one rouge reviewer' do
            # reivewer_1's review for reviewee_1; Numeric value of the answer array
            # for response_1_1: [5, 5, 5, 5, 5]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 2)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 3)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 1)

            # reivewer_2's review for reviewee_1; Numeric value of the answer array
            # for response_1_2: [3, 3, 3, 3, 3]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_2.id, answer: 2)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_2.id, answer: 5)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_2.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_2.id, answer: 3)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_2.id, answer: 1)

            # reivewer_3's review for reviewee_1; Numeric value of the answer array
            # for response_1_3: [1, 1, 1, 1, 1]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_3.id, answer: 1)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_3.id, answer: 1)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_3.id, answer: 1)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_3.id, answer: 1)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_3.id, answer: 1)
  
          # choose hammer algorithm without expert grade (instructor's given grade)
          params = { assignment_id: 1, round_num: 1, algorithm: 'hammer', checkbox: { expert_grade: 'empty' } }
          session = { user: build(:instructor, id: 1) }
  
          client = ReputationWebServiceController.new.client
  
          req = ReputationWebServiceController.new.send_post_request
          expect(true).to eq(true)

          # Should return reivewer_1: 2.0, reivewer_2: 2.0, reivewer_3: 0.5
        end

        it 'all equal reputation' do
            # reivewer_1's review for reviewee_1; Numeric value of the answer array
            # for response_1_1: [5, 5, 5, 5, 5]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 5)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 4)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 3)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 2)

            # reivewer_2's review for reviewee_1; Numeric value of the answer array
            # for response_1_2: [3, 3, 3, 3, 3]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_2.id, answer: 5)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_2.id, answer: 3)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_2.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_2.id, answer: 4)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_2.id, answer: 2)

            # reivewer_3's review for reviewee_1; Numeric value of the answer array
            # for response_1_3: [1, 1, 1, 1, 1]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_3.id, answer: 4)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_3.id, answer: 3)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_3.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_3.id, answer: 3)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_3.id, answer: 2)
  
          # choose hammer algorithm without expert grade (instructor's given grade)
          params = { assignment_id: 1, round_num: 1, algorithm: 'hammer', checkbox: { expert_grade: 'empty' } }
          session = { user: build(:instructor, id: 1) }
  
          client = ReputationWebServiceController.new.client

          req = ReputationWebServiceController.new.send_post_request
          expect(true).to eq(true)

          # Should return reivewer_1: 1.0, reivewer_2: 1,0, reivewer_3: 1.0
        end

        it 'testing random scores reputation' do
            # reivewer_1's review for reviewee_1; Numeric value of the answer array
            # for response_1_1: [5, 5, 5, 5, 5]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 2)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 3)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 1)

            # reivewer_2's review for reviewee_1; Numeric value of the answer array
            # for response_1_2: [3, 3, 3, 3, 3]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_2.id, answer: 1)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_2.id, answer: 2)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_2.id, answer: 3)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_2.id, answer: 4)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_2.id, answer: 5)

            # reivewer_3's review for reviewee_1; Numeric value of the answer array
            # for response_1_3: [1, 1, 1, 1, 1]
            create(:answer, question_id: @question_1_1.id, response_id: @response_1_3.id, answer: 3)
            create(:answer, question_id: @question_1_2.id, response_id: @response_1_3.id, answer: 5)
            create(:answer, question_id: @question_1_3.id, response_id: @response_1_3.id, answer: 4)
            create(:answer, question_id: @question_1_4.id, response_id: @response_1_3.id, answer: 2)
            create(:answer, question_id: @question_1_5.id, response_id: @response_1_3.id, answer: 1)
  
          # choose hammer algorithm without expert grade (instructor's given grade)
          params = { assignment_id: 1, round_num: 1, algorithm: 'hammer', checkbox: { expert_grade: 'empty' } }
          session = { user: build(:instructor, id: 1) }
  
          client = ReputationWebServiceController.new.client

          req = ReputationWebServiceController.new.send_post_request
          expect(true).to eq(true)

          # Should return reivewer_1: 2.4, reivewer_2: 0.5, reivewer_3: 1.5
        end
      end
    end
  end
  