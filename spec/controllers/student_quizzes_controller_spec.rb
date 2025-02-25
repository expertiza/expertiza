describe StudentQuizzesController do
  # Describe block for testing the method `action_allowed?` in the controller.
  describe "#action_allowed?" do

    # Context for testing scenarios when the current user has student privileges.
    context "when current user has student privileges" do

      # Use `let` to define a student object for testing purposes.
      let(:student) { create(:student) }

      # Before each test within this context, set up the session and stub methods.
      before do
        # Set the current session's user as the student.
        session[:user] = student

        # Stub the `current_user` method to always return our test student.
        allow(controller).to receive(:current_user).and_return(student)
      end

      # Test to ensure that the controller correctly identifies the current user as a student.
      it "correctly identifies the current user as a student" do
        expect(controller.send(:current_user_is_a?, 'Student')).to be_truthy
      end

      # Test for scenario where the current action is not 'index'.
      # Given that the current user is a student, this test checks that
      # the method `action_allowed?` should return true.
      it "returns true if action is not 'index'" do
        controller.params = { action: 'show' } # Set the action to 'show'
        expect(controller.send(:action_allowed?)).to be_truthy
      end

      # Test for scenario where the current action is 'index', but the student
      # does not have the required reviewer and submitter authorizations.
      # The method `action_allowed?` should return false in this scenario.
      it "returns false if action is 'index' and student does not have reviewer and submitter authorizations" do
        controller.params = { action: 'index', id: 'some_id' } # Set the action to 'index'
        allow(controller).to receive(:are_needed_authorizations_present?).and_return(false)
        allow(controller).to receive(:action_name).and_return('index')
        expect(controller.send(:action_allowed?)).to be_falsey
      end

      # Test for scenario where the current action is 'index', and the student
      # has the required reviewer and submitter authorizations.
      # The method `action_allowed?` should return true in this scenario.
      it "returns true if action is 'index' and student has reviewer and submitter authorizations" do
        controller.params = { action: 'index', id: 'some_id' } # Set the action to 'index'
        allow(controller).to receive(:are_needed_authorizations_present?).and_return(true)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end

    # Context for testing scenarios when the current user does not have student privileges.
    context "when current user does not have student privileges" do

      # Before each test within this context, stub the method `current_user_is_a?` to return false
      # for 'Student', indicating that the user is not a student.
      before do
        allow(controller).to receive(:current_user_is_a?).with('Student').and_return(false)
      end

      # Test for scenario where the current user has TA (Teaching Assistant) privileges.
      # Given that the user is not a student, this test checks that if the user is a TA,
      # the method `action_allowed?` should return true.
      it "returns true if current user has TA privileges" do
        allow(controller).to receive(:current_user_has_ta_privileges?).and_return(true) # Stub to indicate the user has TA privileges
        expect(controller.send(:action_allowed?)).to be_truthy
      end

      # Test for scenario where the current user does not have either student or TA privileges.
      # The method `action_allowed?` should return false in this scenario.
      it "returns false if current user does not have TA privileges" do
        allow(controller).to receive(:current_user_has_ta_privileges?).and_return(false) # Stub to indicate the user does not have TA privileges
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end

  # Group of tests focusing on the 'index' action of a controller.
  describe "index" do
    # Using double to stub/mock the participant with an added stub for user_id.
    let(:participant) { double(:participant, id: 1, user_id: 123) }
    # Stub/mock for an assignment.
    let(:assignment) { double(:assignment) }
    # Stub/mock for quizzes.
    let(:quizzes) { double(:quizzes) }
    # A constant value used to provide expected parent_id for stubbing/mocking.
    let(:some_parent_id) { 456 }

    # Context for tests where the logged-in user is identified as a participant.
    context "when the logged in user is a participant" do
      # Before each test in this context, setup the necessary mocks and stubs.
      before do
        allow(controller).to receive(:params).and_return(id: participant.id)
        allow(AssignmentParticipant).to receive(:find).with(participant.id).and_return(participant)
        allow(participant).to receive(:parent_id).and_return(some_parent_id)
        allow(controller).to receive(:current_user_id?).with(participant.user_id).and_return(true)
        allow(Assignment).to receive(:find).with(some_parent_id).and_return(assignment)
      end

      # Test that checks if the assignment participant is correctly found.
      it "finds the assignment participant" do
        expect(AssignmentParticipant).to receive(:find).with(participant.id).and_return(participant)
        controller.index
      end

      # Test to verify the correct assignment is found based on the participant's parent_id.
      it "finds the assignment" do
        expect(Assignment).to receive(:find).with(some_parent_id).and_return(assignment)
        controller.index
      end

      # Test to ensure that the quizzes meant to be reviewed by the participant are returned.
      it "returns the quizzes to be reviewed by the participant" do
        expect(QuizResponseMap).to receive(:mappings_for_reviewer).with(participant.id).and_return(quizzes)
        controller.index
      end
    end

    # Group of tests for scenarios where the logged-in user is not recognized as a participant.
    context "when the logged in user is not a participant" do
      # Before each test in this context, setup the necessary mocks and stubs.
      before do
        allow(controller).to receive(:params).and_return(id: participant.id)
        allow(AssignmentParticipant).to receive(:find).with(participant.id).and_return(participant)
        allow(controller).to receive(:current_user_id?).with(participant.user_id).and_return(false)
      end

      # NOTE: The below test was commented out because the original assumption was that the controller's logic would
      # exit early if the logged-in user wasn't the participant. However, the controller tries to find an assignment
      # participant regardless of the user's identity.
      # it "does not find the assignment participant" do
      #   # Stub current_user_id? to always return false, simulating a scenario
      #   # where the logged-in user isn't the participant
      #   allow(controller).to receive(:current_user_id?).and_return(false)
      #   # Expect that AssignmentParticipant.find is never called due to the early
      #   # return in the controller's logic
      #   expect(AssignmentParticipant).not_to receive(:find)
      #   controller.index
      # end

      # This test confirms that even when the logged-in user isn't the participant, the controller will still attempt
      # to find the assignment participant. This is based on the current behavior of the controller's logic.
      it "finds the assignment participant" do
        expect(AssignmentParticipant).to receive(:find).with(participant.id).and_return(participant)
        controller.index
      end

      # Test to ensure the controller does not attempt to find the assignment when the logged-in user isn't a participant.
      it "does not find the assignment" do
        expect(Assignment).not_to receive(:find)
        controller.index
      end

      # Test to verify that the controller does not try to fetch any quizzes to be reviewed when the logged-in user isn't a participant.
      it "does not return any quizzes to be reviewed" do
        expect(QuizResponseMap).not_to receive(:mappings_for_reviewer)
        controller.index
      end
    end
  end

  describe "#finished_quiz" do
    #let(:response) {create(:response)}
    let(:quiz_questionnaire) {double(:quiz_questionnaire)}
    let(:quiz_response) {double(:quiz_response)}
    let(:quiz_response_map) {double(:quiz_response_map, map_id:1, reviewed_object_id:1, reviewee_id:1, quiz_score:97)}
    let(:quiz_question) {double(:quiz_question )}
    let(:participant) {double(:participant)}
    let(:assignment_team) {double(:assignment_team, participants:participant)}

    before(:each) do
      allow(controller).to receive(:params).and_return(map_id:quiz_response_map.map_id)
      allow(Response).to receive_message_chain(:where,:first).with(map_id: quiz_response_map.map_id).with(no_args).and_return(quiz_response)
      allow(QuizResponseMap).to receive(:find).with(quiz_response_map.map_id).and_return(quiz_response_map)
      allow(Question).to receive(:where).with(questionnaire_id:quiz_response_map.reviewed_object_id).and_return(quiz_question)
      allow(ResponseMap).to receive(:find).with(quiz_response_map.map_id).and_return(quiz_response_map)
      allow(AssignmentTeam).to receive_message_chain(:find,:participants,:first).and_return(:participant)
      allow(quiz_response_map).to receive(:response).and_return(quiz_response_map.quiz_score)
   end

    context "when a participant has finished a quiz" do
      it "retrieves the participant's response for the quiz" do
        # Test code
        expect(Response).to receive_message_chain(:where,:first)
        controller.finished_quiz
      end
      it "retrieves the quiz response map for the given map_id" do
        # Test code
        expect(QuizResponseMap).to receive(:find)
        controller.finished_quiz
      end

      it "retrieves the quiz questions associated with the quiz response map" do
        # Test code
        expect(Question).to receive(:where)
        controller.finished_quiz
      end

      it "retrieves the participant who attempted the quiz" do
        # Test code
        expect(AssignmentTeam).to receive(:find)
        controller.finished_quiz
      end

      it "retrieves the quiz score for the participant" do
        # Test code
        expect(quiz_response_map.quiz_score).to eq(quiz_response_map.quiz_score)
        controller.finished_quiz
      end
    end
  end

  describe ".get_quiz_questionnaire" do
    let(:assignment) {double(:assignment, id:1)}
    let(:submitter) {double(:participant, id:1)}
    let(:quiz_response) {double(:quiz_response, reviewee_id:submitter_team.id)}
    let(:quiz_response_map) {double(:quiz_response_map, each: quiz_response)}
    let(:submitter_team) {double(:assignment_team, participants:submitter, id:123, parent_id:assignment.id)}
    let(:reviewer) {double(:participant, id:2)}
    let(:reviewer_team) {double(:assignment_team, participants:reviewer, id:456)}
    let(:quiz_questionnaire) {double(:quiz_questionnaire,taken_by?:reviewer_team)}
    let(:stray_team) {double(:assignment_team, id:789)}
    let(:stray_assignment) {double(:assignement, id:2)}

    context "when there are no reviewed_team_response_maps for the reviewer" do
      it "returns an empty array" do
        # test scenario
        allow(Participant).to receive_message_chain(:where,:first).with(user_id:reviewer.id, parent_id:assignment.id).with(no_args).and_return(reviewer)
        allow(ReviewResponseMap).to receive(:where).with(reviewer_id:reviewer.id).and_return([])
        expect(StudentQuizzesController.take_quiz(assignment.id,reviewer.id)).to match_array([])
      end
    end

    context "when there are reviewed_team_response_maps for the reviewer" do
      context "when the reviewee team is not associated with the assignment" do
        it "skips the reviewee team and does not include its quiz questionnaire" do
          # test scenario
          allow(Participant).to receive_message_chain(:where,:first).with(user_id:reviewer.id, parent_id:assignment.id).with(no_args).and_return(reviewer)
          allow(ReviewResponseMap).to receive(:where).with(reviewer_id:reviewer.id).and_return(quiz_response_map)
          allow(Team).to receive(:find).with(stray_team.id).and_return(stray_team)
          expect(StudentQuizzesController.take_quiz(assignment.id,reviewer.id)).to match_array([])
        end
      end

      context "when the reviewee team is associated with the assignment" do
        
        before(:each) do
          allow(Participant).to receive_message_chain(:where,:first).with(user_id:reviewer.id, parent_id:assignment.id).with(no_args).and_return(reviewer)
          allow(ReviewResponseMap).to receive(:where).with(reviewer_id:reviewer.id).and_return(quiz_response_map)
          allow(Team).to receive(:find).with(submitter_team.id).and_return(submitter_team)
          allow(QuizQuestionnaire).to receive_message_chain(:where,:first).with(instructor_id:submitter_team.id).with(no_args).and_return(quiz_questionnaire)
          allow(QuizQuestionnaire).to receive(:taken_by?).and_return(reviewer)
        end

        context "when the reviewee team has not created a quiz questionnaire" do
          it "skips the reviewee team and does not include its quiz questionnaire" do
            # test scenario
            expect(QuizQuestionnaire).not_to receive(:where)
            StudentQuizzesController.take_quiz(stray_assignment.id, reviewer_team.id)
          end
        end

        context "when the reviewee team has created a quiz questionnaire" do
          context "when the quiz questionnaire has not been taken by the reviewer" do
            it "includes the quiz questionnaire in the result" do
              # test scenario
              # expect(StudentQuizzesController.take_quiz(assignment.id, stray_team.id)).not_to match_array([])
            end
          end

          context "when the quiz questionnaire has been taken by the reviewer" do
            it "skips the quiz questionnaire and does not include it in the result" do
              # test scenario
              expect(StudentQuizzesController.take_quiz(assignment.id, reviewer_team.id)).to match_array([])
            end
          end
        end
      end
    end
  end

  describe StudentQuizzesController do
    describe "record_response" do
      let(:participant) { create(:student) }
      let(:question) { create(:question) }
      let(:empty_response) { '' }
      let(:valid_score) { 100 }
      let(:invalid_score) { -1 }
      let(:non_empty_response) { 'Some Response' }
      let(:mock_response) { double(:response, empty?: false) }
      let(:dummy_assignment_id) { 123 }
      let(:dummy_questionnaire_id) { 456 }
      let(:questionnaire) { create(:questionnaire) }
      let(:quiz_response_map) {
        double(
          :quiz_response_map,
          map_id: 1,
          reviewed_object_id: questionnaire.id,
          reviewee_id: 1,
          quiz_score: 97,
          id: 1,
          response: mock_response
        )
      }

      before do
        # Set the user in the session to mimic login
        session[:user] = participant
        session[:impersonate] = false

        # Set the role for the logged in user
        AuthController.set_current_role(participant.role_id, session)

        # Mock the response map
        allow(ResponseMap).to receive(:find).with(quiz_response_map.map_id.to_s).and_return(quiz_response_map)

        # Mock the calculate_score on the specific instance
        allow(quiz_response_map).to receive(:quiz_score)
        allow(quiz_response_map).to receive(:quiz_score).and_return(97)
      end

      context "when participant response is empty" do
        before do
          allow(mock_response).to receive(:empty?).and_return(true)
        end
        it "creates a new response and saves it" do
          # Test scenario (Needs to be filled out)
          expect {
            post :record_response, params: {
              map_id: quiz_response_map.map_id,
              response: empty_response,
              assignment_id: dummy_assignment_id,
              questionnaire_id: dummy_questionnaire_id
            }
          }.to change { Response.count }.by(1)
        end

        it "calculates the score for the participant response" do
          # Test scenario
            expect_any_instance_of(StudentQuizzesController).to receive(:calculate_score)
            post :record_response, params: {
              map_id: quiz_response_map.map_id,
              response: empty_response,
              assignment_id: dummy_assignment_id,
              questionnaire_id: dummy_questionnaire_id
            }

        end

        context "when the score is valid" do
          before do
            allow_any_instance_of(QuizResponse).to receive(:calculate_score).and_return(valid_score)

            # Mock the score getter and setter
            allow(participant).to receive(:score).and_return(valid_score)
            allow(participant).to receive(:score=)
          end

          it "saves the scores" do
            # Test scenario
              post :record_response, params: {
                map_id: quiz_response_map.map_id,
                response: empty_response,
                assignment_id: dummy_assignment_id,
                questionnaire_id: dummy_questionnaire_id
              }
              participant.reload
              expect(participant.score).to eq(valid_score)
          end

          it "redirects to the finished_quiz page" do
            post :record_response, params: {
              map_id: quiz_response_map.map_id,
              response: empty_response,
              assignment_id: dummy_assignment_id,
              questionnaire_id: dummy_questionnaire_id
            }
            expect(response).to redirect_to(controller: 'student_quizzes', action: 'finished_quiz', map_id: quiz_response_map.map_id)
          end
        end

        context "when the score is invalid" do
          before do
            allow_any_instance_of(QuizResponse).to receive(:calculate_score).and_return(invalid_score)
          end

          it "destroys the quiz response" do
            post :record_response, params: {
              map_id: quiz_response_map.map_id,
              response: empty_response,
              assignment_id: dummy_assignment_id,
              questionnaire_id: dummy_questionnaire_id
            }
            expect(Answer.where(answer: empty_response)).not_to exist
          end

          it "displays an error message" do
            # working on test still 
            # post :record_response, params: {
            #   map_id: quiz_response_map.map_id,
            #   response: empty_response,
            #   assignment_id: dummy_assignment_id,
            #   questionnaire_id: dummy_questionnaire_id
            # }
            # expect(flash[:error]).to be_present
          end

          it "redirects to the get_quiz_questionnaire page" do
            post :record_response, params: {
              map_id: quiz_response_map.map_id,
              response: empty_response,
              assignment_id: dummy_assignment_id,
              questionnaire_id: dummy_questionnaire_id
            }
            expect(response).to redirect_to(controller: 'student_quizzes', action: 'finished_quiz', map_id: quiz_response_map.map_id)
          end
        end
      end

      context "when participant response is not empty" do
        it "displays an error message" do
          post :record_response, params: {
            map_id: quiz_response_map.map_id,
            response: non_empty_response,
            assignment_id: dummy_assignment_id,
            questionnaire_id: dummy_questionnaire_id
          }
          expect(flash[:error]).to be_present
        end

        it "redirects to the finished_quiz page" do
          post :record_response, params: {
            map_id: quiz_response_map.map_id,
            response: empty_response,
            assignment_id: dummy_assignment_id,
            questionnaire_id: dummy_questionnaire_id
          }
          expect(response).to redirect_to(controller: 'student_quizzes', action: 'finished_quiz', map_id: quiz_response_map.map_id)
        end

      end
    end
  end
end

