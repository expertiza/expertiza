describe AnswerTagsController do
  # Set up factory objects for testing
  # These objects simulate database records that are needed for the testing.
  let!(:instructor) { build(:instructor, id: 1) }
  let!(:student) { build(:student, id: 1) }
  let!(:assignment) { create(:assignment, name: 'assignment', directory_path: 'assignment', id: 1) }
  let!(:assignment2) { create(:assignment, name: 'assignment2', directory_path: 'assignment2', id: 2) }
  let!(:questionnaire) { create(:questionnaire, name: 'questionnaire', id: 1) }
  let!(:tag_prompt_deployment) { create(:tag_prompt_deployment, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let!(:tag_prompt_deployment2) { create(:tag_prompt_deployment, id: 2, assignment_id: 2, questionnaire_id: 1) }
  let!(:answer_tag) { create(:answer_tag, id: 1, tag_prompt_deployment_id: 1, user_id: student.id) }

  # Factory objects required for "create_edit" test cases - since creating answer tags and updating answer tags requires pre mapping of answer and tag deployment key constraints
  let!(:student2) { build(:student, id: 2) }
  let!(:assignment3) { create(:assignment, name: 'assignment3', directory_path: 'assignment3', id: 3) }
  let!(:questionnaire1) { create(:questionnaire, name: 'questionnaire1', id: 2) }
  let!(:question1) { create(:question, questionnaire: questionnaire, weight: 2, id: 2, type: 'Criterion') }
  let!(:response_map) { create(:review_response_map, id: 2, reviewed_object_id: 2) }
  let!(:response_record) { create(:response, id: 2, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: 'test comment', response_id: response_record.id) }
  let!(:tag_prompt) { create(:tag_prompt, id: 3, prompt: '??', desc: 'desc', control_type: 'slider') }
  let!(:tag_deploy) { create(:tag_prompt_deployment, id: 3, tag_prompt: tag_prompt, question_type: 'Criterion') }

  # Tests for checking permissions based on user roles and session status
  # To allow the functionality only if the accessing user is having student privileges
  # params: action
  describe '#action_allowed?' do
    # Verifies that students can perform certain actions
    context 'when user with student privileges accesses the controller' do
      before(:each) do
        controller.request.session[:user] = student
      end

      # Tests access to the index action for a student.
      context 'accessing index action' do
        # Ensures students are allowed to access index action.
        it 'allows access' do
          controller.params = { id: '1', action: 'index' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      # Tests access to the create_edit action for a student.
      context 'accessing create_edit action' do
        # Ensures students are allowed to access create_edit action.
        it 'allows access' do
          controller.params = { id: '1', action: 'create_edit' }
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      # Tests access to the destroy action for a student.
      context 'accessing destroy action' do
        # Verifies that access to destroy action is undefined, indicating potential permission denial.
        it 'denies access' do
          controller.params = { id: '1', action: 'destroy' }
          expect(controller.send(:action_allowed?)).to be nil
        end
      end
    end

    # Ensures that actions are restricted when the session is undefined
    context 'with undefined session' do
      # Setup no user session for testing action restrictions.
      before(:each) do
        controller.request.session[:user] = nil
      end

      # Tests index action access with no session.
      context 'accessing index action' do
        # Ensures the index action is inaccessible without a user session.
        it 'denies access' do
          controller.params = { id: '1', action: 'index' }
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      # Tests create_edit action access with no session.
      context 'accessing create_edit action' do
        # Ensures the create_edit action is inaccessible without a user session.
        it 'denies access' do
          controller.params = { id: '1', action: 'create_edit' }
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      # Tests destroy action access with no session.
      context 'accessing destroy action' do
        # Ensures the destroy action's access status is undefined, indicating potential denial without a session.
        it 'denies access' do
          controller.params = { id: '1', action: 'destroy' }
          expect(controller.send(:action_allowed?)).to be nil
        end
      end
    end
  end


  # Test index method used to return all tag prompt deployments in JSON format
  describe '#index' do
  # Tests when tag prompt deployments are queried by a user.
    context 'tag prompt deployments are requested by user' do
      # Setup user session for index action tests.
      before(:each) do
        controller.request.session[:user] = student
      end

      # Tests when no tag prompts are available in the system.
      context 'and none are available' do
        # Verifies that an empty list is returned when no tag prompts exist.
        it 'returns no tag prompts' do
          allow(TagPromptDeployment).to receive(:all).and_return(TagPromptDeployment.none)
          get :index
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when exactly one tag prompt deployment is present in the system.
      context 'and only one is present' do
        # Tests if a single tag prompt deployment is correctly returned by the index action.
        it 'returns a list with only one tag prompt' do
          get :index
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      # Tests when a tag prompt deployment exists without any associated answer tags.
      context 'and only one tag prompt deployment is present but has no answer tag' do
        # Verifies that no tag prompts are returned for an assignment without associated answer tags.
        it 'returns no tag prompts for that assignment' do
          request_params = { assignment_id: 2 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when filtering tag prompt deployments by a specific user_id.
      context 'and only one answer tag is present for the given user_id' do
        # Ensures a single tag prompt associated with the user_id is returned.
        it 'returns a list with one tag prompt' do
          request_params = { user_id: student.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      # Tests when filtering tag prompt deployments by a specific assignment_id.
      context 'and only one answer tag is present for the given assignment_id' do
        # Tests the return of a single tag prompt associated with the assignment_id.
        it 'returns a list with one tag prompt' do
          request_params = { assignment_id: assignment.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      # Tests when filtering tag prompt deployments by a specific questionnaire_id.
      context 'and only one answer tag is present of the given questionnaire_id' do
        # Confirms a single tag prompt associated with the questionnaire_id is returned.
        it 'returns a list with one tag prompt' do
          request_params = { questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      # Tests when specific filters (user_id, assignment_id, and questionnaire_id) are applied together.
      context 'and only one answer tag is present for the given user_id, assignment_id, and questionnaire_id' do
        # Checks the return of a single tag prompt that meets all specified filter criteria.
        it 'returns a list with one tag prompt' do
          request_params = { user_id: student.id, assignment_id: assignment.id, questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(1)
        end
      end

      # Tests when no answer tags are associated with a specific user_id.
      context 'and no answer tags are present for the given user_id' do
        # Verifies that no tag prompts are returned for a user_id with no associated answer tags.
        it 'returns no tag prompts' do
          request_params = { user_id: student2.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are associated with a specific assignment_id.
      context 'and no answer tags are present for the given assignment_id' do
        # Ensures no tag prompts are returned for an assignment_id with no associated answer tags.
        it 'returns no tag prompts' do
          request_params = { assignment_id: assignment3.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are associated with a specific questionnaire_id.
      context 'and no answer tags are present for the given questionnaire_id' do
        # Tests that no tag prompts are returned for a questionnaire_id with no associated answer tags.
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: questionnaire1.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are present for the combined criteria of user_id, assignment_id, and questionnaire_id.
      context 'and no answer tags are present for the given user_id, assignment_id, and questionnaire_id' do
        # Verifies an empty list is returned when filtering by a specific user_id, assignment_id, and questionnaire_id with no associated answer tags.
        it 'returns no tag prompts' do
          request_params = { user_id: student2.id, assignment_id: assignment3.id, questionnaire_id: questionnaire.id }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are associated with an undefined user_id.
      context 'and no answer tags are present for given undefined user_id' do
        # Checks if an empty list is returned when querying with an undefined user_id.
        it 'returns no tag prompts' do
          request_params = { user_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are associated with an undefined assignment_id.
      context 'and no answer tags are present for given undefined assignment_id' do
        # Verifies an empty list is returned when querying with an undefined assignment_id.
        it 'returns no tag prompts' do
          request_params = { assignment_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when no answer tags are associated with an undefined questionnaire_id.
      context 'and no answer tags are present for given undefined questionnnaire_id' do
        # Confirms that querying with an undefined questionnaire_id results in an empty list.
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: 42 }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when the user_id parameter is explicitly set to nil.
      context 'and user_id is nil' do
        # Checks if specifying a nil user_id leads to an empty list returned by the index action.
        it 'returns no tag prompts' do
          request_params = { user_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when the questionnaire_id parameter is explicitly set to nil.
      context 'and questionnaire_id is nil' do
        # Verifies an empty list is returned when the questionnaire_id parameter is nil.
        it 'returns no tag prompts' do
          request_params = { questionnaire_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end

      # Tests when the assignment_id parameter is explicitly set to nil.
      context 'and assignment_id is nil' do
        # Confirms that specifying a nil assignment_id results in an empty list from the index action.
        it 'returns no tag prompts' do
          request_params = { assignment_id: nil }
          get :index, params: request_params
          output = JSON.parse(response.body)
          expect(output.length).to eql(0)
        end
      end
    end
  end


  # To allow creation if not existing and simultaneously updating the new answer tag.
  # params: answer_id (answer id mapping to which tag is being created)
  # params: tag_prompt_deployment_id (tag_prompt id mapping to which tag is being created)
  # params: value (new value to be updated)
  describe '#create_edit' do
    context 'when student tries to create or update the answer tags' do
      # Setup student session for create_edit action tests.
      before(:each) do
        controller.request.session[:user] = student
      end

      # Test case for adding a new entry if it doesn't exist and updating if it does.
      context "when entry doesn't exist" do
        # Verifies that a new answer tag is added or an existing one is updated with the provided value.
        it 'adds entry and adds new value provided as param' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('0')
        end

        # Confirms the API's response for a successful tag creation or update is true, indicating success.
        it 'adds entry and JSON returns true' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          output = JSON.parse(response.body)
          expect(output).to eql(true)
        end
      end

      context "when the entry already exists" do
        # Verifies updating of an answer tag's value by a student, ensuring correct value assignment.
        it 'updates the old value by new value provided as param' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('0')

          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '1' }
          post :create_edit, params: request_params
          expect(response).to have_http_status(:ok)
          expect(AnswerTag.find_by(answer_id: answer.id).value).to eql('1')
        end

        # Verifies that the API response confirms successful update with a true JSON response.
        it 'updates the value and JSON returns true' do
          request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
          post :create_edit, params: request_params
          output = JSON.parse(response.body)
          expect(output).to eql(true)
        end

        # Ensures updating an answer tag is restricted when no valid answer mapping exists (due to foreign key constraints).
        context 'and no mapping is found related to any answer for that tag (foreign key constraint)' do
          it 'restricts updating answer tag by student' do
            request_params = { answer_id: nil, tag_prompt_deployment_id: tag_deploy.id, value: '0' }
            expect do
              post :create_edit, params: request_params
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end

        # Checks that updating is restricted when no valid tag_prompt_deployment mapping exists, adhering to foreign key constraints.
        context 'and no mapping is found related to any tag_prompt_deployment for that tag (foreign key constraint)' do
          it 'restricts updating answer tag by student' do
            request_params = { answer_id: answer.id, tag_prompt_deployment_id: nil, value: '0' }
            expect do
              post :create_edit, params: request_params
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end

        # Validates that an update operation is not permitted without specifying a new value for the answer tag.
        context 'and no updated value is provided for the answer tag' do
          it 'restricts updating answer tag by student' do
            request_params = { answer_id: answer.id, tag_prompt_deployment_id: tag_deploy.id, value: nil }
            expect do
              post :create_edit, params: request_params
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end
  end
end
