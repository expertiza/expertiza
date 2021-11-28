describe ReputationWebServiceController do

  let(:instructor){build(:instructor, id:1)}
  describe 'custom test' do
    before(:each) do
      @assignment_1 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 5, num_reviewers: 5, num_reviews_allowed: 5, rounds_of_reviews: 2, reputation_algorithm: 'lauw', id: 1)
      @assignment_2 = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 5, num_reviewers: 5, num_reviews_allowed: 5, rounds_of_reviews: 2, reputation_algorithm: 'hamer', id: 2)
      @questionnaire_1 = create(:questionnaire, min_question_score: 0, max_question_score: 5, type: 'ReviewQuestionnaire', id: 1)
      @assignment_questionnaire_1_1 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
      @assignment_questionnaire_1_2 = create(:assignment_questionnaire, assignment_id: @assignment_1.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2)
      @assignment_questionnaire_2_1 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 1)
      @assignment_questionnaire_2_2 = create(:assignment_questionnaire, assignment_id: @assignment_2.id, questionnaire_id: @questionnaire_1.id, used_in_round: 2, id: 4)

      @question_1_1 = create(:question, questionnaire_id: @questionnaire_1.id, id: 1)
      @question_1_2 = create(:question, questionnaire_id: @questionnaire_1.id, id: 2)
      @question_1_3 = create(:question, questionnaire_id: @questionnaire_1.id, id: 3)
      @question_1_4 = create(:question, questionnaire_id: @questionnaire_1.id, id: 4)
      @question_1_5 = create(:question, questionnaire_id: @questionnaire_1.id, id: 5)

      @reviewer_1 = create(:participant, can_review: 1)
      @reviewer_2 = create(:participant, can_review: 1)
      @reviewer_3 = create(:participant, can_review: 1)
      @reviewer_4 = double(:participant, can_review: 1)
      @reviewer_5 = double(:participant, can_review: 1)

      @reviewee_1 = create(:assignment_team, assignment: @assignment)
      @reviewee_2 = create(:assignment_team, assignment: @assignment)
      @reviewee_3 = create(:assignment_team, assignment: @assignment)

      @response_map_1_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_1.id)
      @response_map_1_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_1.id)
      @response_map_1_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_1.id)
      #@response_map_1_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_1.id)
      #@response_map_1_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_1.id)
      @response_map_2_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_2.id)
      @response_map_2_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_2.id)
      @response_map_2_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_2.id)
      #@response_map_2_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_2.id)
      #@response_map_2_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_2.id)
      @response_map_3_1 = create(:review_response_map, reviewer_id: @reviewer_1.id, reviewee_id: @reviewee_3.id)
      @response_map_3_2 = create(:review_response_map, reviewer_id: @reviewer_2.id, reviewee_id: @reviewee_3.id)
      @response_map_3_3 = create(:review_response_map, reviewer_id: @reviewer_3.id, reviewee_id: @reviewee_3.id)
      #@response_map_3_4 = create(:review_response_map, reviewer_id: @reviewer_4.id, reviewee_id: @reviewee_3.id)
      #@response_map_3_5 = create(:review_response_map, reviewer_id: @reviewer_5.id, reviewee_id: @reviewee_3.id)

      @response_1_1 = create(:response, is_submitted: true, map_id: @response_map_1_1.id)
      @response_1_2 = create(:response, is_submitted: true, map_id: @response_map_1_2.id)
      @response_1_3 = create(:response, is_submitted: true, map_id: @response_map_1_3.id)
      #@response_1_4 = create(:response, is_submitted: true, map_id: @response_map_1_4.id)
      #@response_1_5 = create(:response, is_submitted: true, map_id: @response_map_1_5.id)
      @response_2_1 = create(:response, is_submitted: true, map_id: @response_map_2_1.id)
      @response_2_2 = create(:response, is_submitted: true, map_id: @response_map_2_2.id)
      @response_2_3 = create(:response, is_submitted: true, map_id: @response_map_2_3.id)
      #@response_2_4 = create(:response, is_submitted: true, map_id: @response_map_2_4.id)
      #@response_2_5 = create(:response, is_submitted: true, map_id: @response_map_2_5.id)
      @response_3_1 = create(:response, is_submitted: true, map_id: @response_map_3_1.id)
      @response_3_2 = create(:response, is_submitted: true, map_id: @response_map_3_2.id)
      @response_3_3 = create(:response, is_submitted: true, map_id: @response_map_3_3.id)
      #@response_3_4 = create(:response, is_submitted: true, map_id: @response_map_3_4.id)
      #@response_3_5 = create(:response, is_submitted: true, map_id: @response_map_3_5.id)
    end

    it 'scenario 1' do
      # reivewer_1's review for reviewee_1: [5, 5, 5, 5, 5]
      create(:answer, question_id: @question_1_1.id, response_id: @response_1_1.id, answer: 5)
      create(:answer, question_id: @question_1_2.id, response_id: @response_1_1.id, answer: 5)
      create(:answer, question_id: @question_1_3.id, response_id: @response_1_1.id, answer: 5)
      create(:answer, question_id: @question_1_4.id, response_id: @response_1_1.id, answer: 5)
      create(:answer, question_id: @question_1_5.id, response_id: @response_1_1.id, answer: 5)

      # reivewer_2's review for reviewee_1: [3, 3, 3, 3, 3]
      create(:answer, question_id: @question_1_1.id, response_id: @response_1_2.id, answer: 3)
      create(:answer, question_id: @question_1_2.id, response_id: @response_1_2.id, answer: 3)
      create(:answer, question_id: @question_1_3.id, response_id: @response_1_2.id, answer: 3)
      create(:answer, question_id: @question_1_4.id, response_id: @response_1_2.id, answer: 3)
      create(:answer, question_id: @question_1_5.id, response_id: @response_1_2.id, answer: 3)

      # reivewer_3's review for reviewee_1: [1, 1, 1, 1, 1]
      create(:answer, question_id: @question_1_1.id, response_id: @response_1_3.id, answer: 1)
      create(:answer, question_id: @question_1_2.id, response_id: @response_1_3.id, answer: 1)
      create(:answer, question_id: @question_1_3.id, response_id: @response_1_3.id, answer: 1)
      create(:answer, question_id: @question_1_4.id, response_id: @response_1_3.id, answer: 1)
      create(:answer, question_id: @question_1_5.id, response_id: @response_1_3.id, answer: 1)

      #result = ReputationWebServiceController.new.db_query(1, 1, false)
      #expect(result).to eq([[2, 1, 100.0], [3, 1, 60.0], [4, 1, 20.0]])
      result = ReputationWebServiceController.new.json_generator(1, 0, 1)
      expect(result).to eq({"submission1"=>{"stu2"=>100.0, "stu3"=>60.0, "stu4"=>20.0}})
      #repeat for different answers
    end
  end


=begin
  # TODO added by Dong Li
  describe 'custom test' do
    let(:assignment_1) { double('Assignment', id: 1, rounds_of_reviews:2, reputation_algorithm: 'lauw') }
    let(:assignment_2) { double('Assignment', id: 2, rounds_of_reviews:2, reputation_algorithm: 'hamer') }

    let(:questionnaire_1) { double('Questionnaire', name: 'q1', instructor_id: 1, min_question_score: 1, max_question_score: 5) }
    let(:questionnaire_2) { double('Questionnaire', name: 'q2', instructor_id: 1, min_question_score: 1, max_question_score: 5) }

    let(:assignment_questionnaire_1_1) { double('AssignmentQuestionnaire', assignment_id: 1, questionnaire_id: 1, user_id: 1,
                                             questionnaire_weight: 100, used_in_round: 1) }
    let(:assignment_questionnaire_1_2) { double('AssignmentQuestionnaire', assignment_id: 1, questionnaire_id: 2, user_id: 1,
                                             questionnaire_weight: 100, used_in_round: 2) }
    let(:assignment_questionnaire_2_1) { double('AssignmentQuestionnaire', assignment_id: 2, questionnaire_id: 1, user_id: 1,
                                             questionnaire_weight: 100, used_in_round: 1) }
    let(:assignment_questionnaire_2_2) { double('AssignmentQuestionnaire', assignment_id: 2, questionnaire_id: 2, user_id: 1,
                                             questionnaire_weight: 100, used_in_round: 2) }

    let(:user_1) {double('User', id: 1)}
    let(:user_2) {double('User', id: 2)}
    let(:user_3) {double('User', id: 3)}
    let(:user_4) {double('User', id: 4)}
    let(:user_5) {double('User', id: 5)}

    let(:reviewer_1) {double('Participant', id: 1, name: 'reviewer_1', user: user_1)}
    let(:reviewer_2) {double('Participant', id: 2, name: 'reviewer_2', user: user_2)}
    let(:reviewer_3) {double('Participant', id: 3, name: 'reviewer_3', user: user_3)}
    let(:reviewer_4) {double('Participant', id: 4, name: 'reviewer_4', user: user_4)}
    let(:reviewer_5) {double('Participant', id: 5, name: 'reviewer_5', user: user_5)}

    let(:reviewee_1) { double('AssignmentTeam', name: 'reviewee_1', id: 2) }
    let(:reviewee_2) { double('AssignmentTeam', name: 'reviewee_2', id: 3) }
    let(:reviewee_3) { double('AssignmentTeam', name: 'reviewee_3', id: 4) }

    let(:question_1_1) {double('Question', id:1, txt: 'question1', questionnaire_id: 1, seq: 1.00, questionnaire: questionnaire_1, type: "Criterion", weight: 1)}
    let(:question_1_2) {double('Question', id:2, txt: 'question2', questionnaire_id: 1, seq: 2.00, questionnaire: questionnaire_1, type: "Criterion", weight: 1)}
    let(:question_1_3) {double('Question', id:3, txt: 'question3', questionnaire_id: 1, seq: 3.00, questionnaire: questionnaire_1, type: "Criterion", weight: 1)}
    let(:question_1_4) {double('Question', id:4, txt: 'question4', questionnaire_id: 1, seq: 4.00, questionnaire: questionnaire_1, type: "Criterion", weight: 1)}
    let(:question_1_5) {double('Question', id:5, txt: 'question5', questionnaire_id: 1, seq: 4.00, questionnaire: questionnaire_1, type: "Criterion", weight: 1)}
    let(:question_2_1) {double('Question', id:6, txt: 'question1', questionnaire_id: 2, seq: 1.00, questionnaire: questionnaire_2, type: "Criterion", weight: 1)}
    let(:question_2_2) {double('Question', id:7, txt: 'question2', questionnaire_id: 2, seq: 2.00, questionnaire: questionnaire_2, type: "Criterion", weight: 1)}
    let(:question_2_3) {double('Question', id:8, txt: 'question3', questionnaire_id: 2, seq: 3.00, questionnaire: questionnaire_2, type: "Criterion", weight: 1)}
    let(:question_2_4) {double('Question', id:9, txt: 'question4', questionnaire_id: 2, seq: 4.00, questionnaire: questionnaire_2, type: "Criterion", weight: 1)}
    let(:question_2_5) {double('Question', id:10, txt: 'question5', questionnaire_id: 2, seq: 4.00, questionnaire: questionnaire_2, type: "Criterion", weight: 1)}

    let(:response_1_1) {double('Response', id:1, map_id: 1, round: 1)}
    let(:response_1_2) {double('Response', id:2, map_id: 2, round: 1)}
    let(:response_1_3) {double('Response', id:3, map_id: 3, round: 1)}
    let(:response_1_4) {double('Response', id:4, map_id: 4, round: 1)}
    let(:response_1_5) {double('Response', id:5, map_id: 5, round: 1)}
    let(:response_2_1) {double('Response', id:1, map_id: 6, round: 1)}
    let(:response_2_2) {double('Response', id:2, map_id: 7, round: 1)}
    let(:response_2_3) {double('Response', id:3, map_id: 8, round: 1)}
    let(:response_2_4) {double('Response', id:4, map_id: 9, round: 1)}
    let(:response_2_5) {double('Response', id:5, map_id: 10, round: 1)}

    # review response map of reviewer
    let(:review_response_map_1_1) do
      double('ReviewResponseMap', id: 1, assignment: assignment_1,
             reviewer: reviewer_1, reviewer_id: 1, reviewee: reviewee_1, reviewee_id: 1, response: [response_1_1])
    end
    let(:review_response_map_1_2) do
      double('ReviewResponseMap', id: 2, assignment: assignment_1,
             reviewer: reviewer_2, reviewer_id: 2, reviewee: reviewee_1, reviewee_id: 1, response: [response_1_2])
    end

    before(:each) do
      allow(Assignment).to receive(:find_by).with(id: '1').and_return(assignment_1)
      instructor = build(:instructor)
      stub_current_user(instructor, instructor.role.name, instructor.role)
      # allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1, calibrate_to: false).and_return(review_response_map1)
      allow(ReviewResponseMap).to receive(:where).with('reviewed_object_id in (?) and calibrate_to = ?', [1], false).and_return([review_response_map_1_1, review_response_map_1_2])

      allow(AssignmentTeam).to receive(:find).with(1).and_return(reviewee_1)
      allow(AssignmentTeam).to receive(:find).with(2).and_return(reviewee_2)
      allow(AssignmentTeam).to receive(:find).with(3).and_return(reviewee_3)

      allow(reviewer_1).to receive(:get_reviewer).and_return(reviewer_1)
      allow(reviewer_2).to receive(:get_reviewer).and_return(reviewer_2)
      allow(reviewer_3).to receive(:get_reviewer).and_return(reviewer_3)
      allow(reviewer_4).to receive(:get_reviewer).and_return(reviewer_4)
      allow(reviewer_5).to receive(:get_reviewer).and_return(reviewer_5)

#      allow(Answer).to receive(:where).with(response_id: 1).and_return([answer_1_1, answer_1_2, answer_1_3, answer_1_4])
#      allow(Answer).to receive(:where).with(response_id: 2).and_return([answer_2_1, answer_2_2, answer_2_3, answer_2_4])

    end

    context 'test db_query' do
      it 'query Peer-Review grade of two reviewers' do

#        let(:answer_1_1) {double('Answer',id:1, question_id: 1, answer: 5, comment: "None", response_id: 1, question: question_1_1)}
#    let(:answer_1_2) {double('Answer',id:2, question_id: 2, answer: 5, comment: "None", response_id: 1, question: question_1_2)}
#    let(:answer_1_3) {double('Answer',id:3, question_id: 3, answer: 5, comment: "None", response_id: 1, question: question_1_3)}
#    let(:answer_1_4) {double('Answer',id:4, question_id: 4, answer: 5, comment: "None", response_id: 1, question: question_1_4)}
#    let(:answer_2_1) {double('Answer',id:5, question_id: 1, answer: 1, comment: "None", response_id: 2, question: question_2_1)}
#    let(:answer_2_2) {double('Answer',id:6, question_id: 2, answer: 1, comment: "None", response_id: 2, question: question_2_2)}
#    let(:answer_2_3) {double('Answer',id:7, question_id: 3, answer: 1, comment: "None", response_id: 2, question: question_2_3)}
#    let(:answer_2_4) {double('Answer',id:8, question_id: 4, answer: 1, comment: "None", response_id: 2, question: question_2_4)}

        create(:answer, id: 1, question_id: 1, answer: 5, response_id: 1 )
        create(:answer, id: 2, question_id: 2, answer: 5, response_id: 1, question: question_1_2 )
        create(:answer, id: 3, question_id: 3, answer: 5, response_id: 1, question: question_1_3 )
        create(:answer, id: 4, question_id: 4, answer: 5, response_id: 1, question: question_1_4 )
        create(:answer, id: 5, question_id: 1, answer: 1, response_id: 2, question: question_2_1 )
        create(:answer, id: 6, question_id: 2, answer: 1, response_id: 2, question: question_2_2 )
        create(:answer, id: 7, question_id: 3, answer: 1, response_id: 2, question: question_2_3 )
        create(:answer, id: 8, question_id: 4, answer: 1, response_id: 2, question: question_2_4 )
        result = ReputationWebServiceController.new.db_query(1, 1, false)
        expect(result).to eq([[1, 2, 100.0], [2, 2, 20.0]])
      end
    end

    # context 'test send post request' do
    #   it 'test 1' do
    #     params = {assignment_id: 1, round_num: 1, algorithm: 'hammer', checkbox: {expert_grade: "empty"}}
    #     session = {user: build(:instructor, id: 1)}
    #
    #     get :send_post_request, params, session
    #     expect(response).to redirect_to '/reputation_web_service/client'
    #   end
    # end

  end
=end
end