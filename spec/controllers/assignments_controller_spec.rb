describe AssignmentsController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'test_assignment',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment2) do
    build(:assignment, id: 2, name: 'new test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'new_test_assignment',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }
  let(:questionnaire) { build(:questionnaire, id: 666) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, id: 1, questionnaire: questionnaire) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = { id: '1', action: 'edit' }
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the instructor of current assignment' do
        it 'allows certain action' do
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the ta of the course which current assignment belongs to' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(true)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is a ta but not the ta of the course which current assignment belongs to' do
        it 'does not allow certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(false)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when current user is the instructor of the course which current assignment belongs to' do
        it 'allows certain action' do
          stub_current_user(instructor2, instructor2.role.name, instructor2.role)
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 66))
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is an instructor but not the instructor of current course or current assignment' do
        it 'does not allow certain action' do
          stub_current_user(instructor2, instructor2.role.name, instructor2.role)
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 666))
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is not edit and update' do
      before(:each) do
        controller.params = { id: '1', action: 'new' }
      end

      context 'when the role current user is super admin/admin/instructor/ta' do
        it 'allows certain action except edit and update' do
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role current user is student' do
        it 'does not allow certain action' do
          stub_current_user(student, student.role.name, student.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  describe '#new' do
    it 'creates a new AssignmentForm object and renders assignment#new page' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    before(:each) do
      allow(AssignmentForm).to receive(:new).with(any_args).and_return(assignment_form)
      @used_params = {
        button: true,
        assignment_form: {
          assignment_questionnaire: [{ 'assignment_id' => '1', 'questionnaire_id' => '666', 'dropdown' => 'true',
                                       'questionnaire_weight' => '100', 'notification_limit' => '15', 'used_in_round' => '1' }],
          due_date: [{ 'id' => '', 'parent_id' => '', 'round' => '1', 'deadline_type_id' => '1', 'due_at' => '2017/12/05 00:00', 'submission_allowed_id' => '3', 'review_allowed_id' => '1', 'teammate_review_allowed_id' => '3', 'review_of_review_allowed_id' => '1', 'threshold' => '1' },
                     { 'id' => '', 'parent_id' => '', 'round' => '1', 'deadline_type_id' => '2', 'due_at' => '2017/12/02 00:00', 'submission_allowed_id' => '1', 'review_allowed_id' => '3', 'teammate_review_allowed_id' => '3', 'review_of_review_allowed_id' => '1', 'threshold' => '1' }],
          assignment: {
            instructor_id: 2,
            course_id: 1,
            max_team_size: 1,
            id: 1,
            name: 'test assignment',
            directory_path: '/test',
            spec_location: '',
            private: false,
            show_teammate_reviews: false,
            require_quiz: false,
            num_quiz_questions: 0,
            staggered_deadline: false,
            microtask: false,
            reviews_visible_to_all: false,
            is_calibrated: false,
            availability_flag: true,
            reputation_algorithm: 'Lauw',
            simicheck: -1,
            simicheck_threshold: 100
          }
        }
      }
      @new_params = {
        button: true,
        assignment_form: {
          assignment_questionnaire: [{ 'assignment_id' => '1', 'questionnaire_id' => '666', 'dropdown' => 'true',
                                       'questionnaire_weight' => '100', 'notification_limit' => '15', 'used_in_round' => '1' }],
          due_date: [{ 'id' => '', 'parent_id' => '', 'round' => '1', 'deadline_type_id' => '1', 'due_at' => '2017/12/05 00:00', 'submission_allowed_id' => '3', 'review_allowed_id' => '1', 'teammate_review_allowed_id' => '3', 'review_of_review_allowed_id' => '1', 'threshold' => '1' },
                     { 'id' => '', 'parent_id' => '', 'round' => '1', 'deadline_type_id' => '2', 'due_at' => '2017/12/02 00:00', 'submission_allowed_id' => '1', 'review_allowed_id' => '3', 'teammate_review_allowed_id' => '3', 'review_of_review_allowed_id' => '1', 'threshold' => '1' }],
          assignment: {
            instructor_id: 2,
            course_id: 1,
            max_team_size: 1,
            id: 2,
            name: 'new test assignment',
            directory_path: 'new_test_assignment',
            spec_location: '',
            private: false,
            show_teammate_reviews: false,
            require_quiz: false,
            num_quiz_questions: 0,
            staggered_deadline: false,
            microtask: false,
            reviews_visible_to_all: false,
            is_calibrated: false,
            availability_flag: true,
            reputation_algorithm: 'Lauw',
            simicheck: -1,
            simicheck_threshold: 100
          }
        }
      }
    end
    context 'when assignment_form is saved successfully' do
      it 'redirects to assignment#edit page' do
        allow(assignment_form).to receive(:assignment).and_return(assignment2)
        allow(Assignment).to receive(:find_by).with(name: 'new test assignment', course_id: 1).and_return(nil)
        allow(Assignment).to receive(:find_by).with(directory_path: 'new_test_assignment', course_id: 1).and_return(nil)
        allow(assignment_form).to receive(:save).and_return(true)
        allow_any_instance_of(AssignmentsController).to receive(:assignment_by_name_and_course).and_return(assignment2)
        allow(assignment_form).to receive(:create_assignment_node).and_return(double('node'))
        allow(assignment_form).to receive(:update).with(any_args).and_return(true)
        allow(Assignment).to receive(:find).and_return(assignment2)
        allow(assignment2).to receive(:id).and_return('2')
        allow_any_instance_of(AssignmentsController).to receive(:undo_link)
          .with('Assignment "new test assignment" has been created successfully. ').and_return(true)
        post :create, params: @new_params
        expect(response).to redirect_to('/assignments/2/edit')
      end
    end

    context 'when assignment_form is not saved successfully' do
      it 'redirect to assignments#new page' do
        allow(assignment_form).to receive(:save).and_return(false)
        post :create, params: @used_params
        expect(response).to redirect_to('/assignments/new?private=1')
      end
    end

    # Create an assignment with name that already exists and expect the create method in assignments_controller_spec.rb to throw error
    context 'when assignment_form name already exists and is not saved properly' do
      it 'redirects to assignment#new page' do
        allow(assignment_form).to receive(:assignment).and_return(assignment)
        allow(Assignment).to receive(:find_by).with(any_args).and_return(false)
        allow(assignment_form).to receive(:save).and_return(true)
        allow(assignment_form).to receive(:create_assignment_node).and_return(double('node'))
        allow(assignment_form).to receive(:update).with(any_args).and_return(true)
        allow(assignment).to receive(:id).and_return(1)
        allow(Assignment).to receive(:find_by).with(course_id: 1, name: 'test assignment').and_return(assignment)
        post :create, params: @used_params
        expect(flash[:error]).to eq('Failed to create assignment.<br>  test assignment already exists as an assignment name')
        expect(response).to redirect_to('/assignments/new?private=1')
      end
    end
  end

  describe '#edit' do
    context 'when assignment has staggered deadlines' do
      it 'shows an error flash message and renders edit page' do
        allow(SignUpTopic).to receive(:where).with(assignment_id: assignment.id.to_s).and_return([double('SignUpTopic'), double('SignUpTopic')])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id.to_s)
                                                         .and_return([assignment_questionnaire])
        allow(Questionnaire).to receive(:where).with(id: assignment_questionnaire.questionnaire_id).and_return([double('Questionnaire', type: 'ReviewQuestionnaire')])
        assignment_due_date = build(:assignment_due_date)
        allow(AssignmentDueDate).to receive(:where).with(parent_id: assignment.id.to_s).and_return([assignment_due_date])
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :edit, params: request_params, session: user_session
        expect(flash.now[:error]).to eq('You did not specify all the necessary rubrics. You need <b>[AuthorFeedback, TeammateReview] '\
          "</b> of assignment <b>test assignment</b> before saving the assignment. You can assign rubrics <a id='go_to_tabs2' style='color: blue;'>here</a>.")
        expect(controller.instance_variable_get(:@metareview_allowed)).to be false
        expect(controller.instance_variable_get(:@drop_topic_allowed)).to be false
        expect(controller.instance_variable_get(:@signup_allowed)).to be false
        expect(controller.instance_variable_get(:@team_formation_allowed)).to be false
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#update' do
    context 'when params does not have key :assignment_form' do
      context 'when assignment is saved successfully' do
        it 'shows a note flash message and redirects to tree_display#index page' do
          allow(assignment).to receive(:save).and_return(true)
          request_params = {
            id: 1,
            course_id: 1
          }
          user_session = { user: instructor }
          post :update, params: request_params, session: user_session
          expect(flash[:note]).to eq('The assignment was successfully saved.')
          expect(response).to redirect_to('/tree_display/list')
        end
      end

      context 'when assignment is not saved successfully' do
        it 'displays an error flash message and redirects to assignments#edit page' do
          allow(assignment).to receive(:save).and_return(false)
          request_params = {
            id: 1,
            course_id: 1
          }
          user_session = { user: instructor }
          post :update, params: request_params, session: user_session
          expect(flash[:error]).to eq('Failed to save the assignment: ')
          expect(response).to redirect_to('/assignments/1/edit')
        end
      end
    end

    context 'when params has key :assignment_form' do
      before(:each) do
        new_assignment_questionnaire = AssignmentQuestionnaire.new
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: '1').and_return([assignment_questionnaire])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 2).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, questionnaire_id: nil).and_return([])
        allow(AssignmentQuestionnaire).to receive(:new).and_return(new_assignment_questionnaire)
        allow(Questionnaire).to receive(:find).with('666').and_return(questionnaire)
        allow(new_assignment_questionnaire).to receive(:save).and_return(true)
        @params = {
          vary_by_topic?: true,
          id: 1,
          course_id: 1,
          set_pressed: {
            bool: 'true'
          },
          assignment_form: {
            assignment_questionnaire: [{ 'assignment_id' => '1', 'questionnaire_id' => '666', 'dropdown' => 'true',
                                         'questionnaire_weight' => '0', 'notification_limit' => '15', 'used_in_round' => '1' }],
            assignment: {
              instructor_id: 2,
              course_id: 1,
              max_team_size: 1,
              id: 2,
              name: 'test assignment',
              directory_path: '/test',
              spec_location: '',
              show_teammate_reviews: false,
              require_quiz: false,
              num_quiz_questions: 0,
              staggered_deadline: false,
              microtask: false,
              reviews_visible_to_all: false,
              is_calibrated: false,
              availability_flag: true,
              reputation_algorithm: 'Lauw',
              simicheck: -1,
              simicheck_threshold: 100
            }
          }
        }
      end
      context 'when the timezone preference of current user is nil and assignment form updates attributes successfully' do
        it 'shows an error message and redirects to assignments#edit page' do
          instructor.timezonepref = nil
          allow(User).to receive(:find).and_return(double('User', timezonepref: 'Eastern Time (US & Canada)'))
          user_session = { user: instructor }
          post :update, params: @params, session: user_session
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to eq('We strongly suggest that instructors specify their preferred timezone to guarantee the correct display time. '\
                                      'For now we assume you are in Eastern Time (US & Canada)')
          expect(response).to render_template('assignments/edit/_topics')
        end
      end

      context 'when update assignment_form of the assignment with @params attributes' do
        it 'renders assignments/edit/_topic page' do
          user_session = { user: instructor }
          post :update, params: @params, session: user_session
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to be nil
          expect(response).to render_template('assignments/edit/_topics')
        end
      end

      context 'when update assignment_form is called on an empty questionnaire of non-zero weight' do
        it 'shows an error message and redirects to assignments#edit page' do
          @params[:assignment_form][:assignment_questionnaire][0]['questionnaire_weight'] = '100'
          user_session = { user: instructor }
          post :update, params: @params, session: user_session
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to eq('A rubric has no ScoredQuestions, but still has a weight. Please change the weight to 0.')
          expect(response).to render_template('assignments/edit/_topics')
        end
      end
    end
  end

  describe '#show' do
    it 'renders assignments#show page' do
      get :show, params: { id: 1 }
      expect(response).to render_template(:show)
    end
  end

  describe '#copy' do
    let(:new_assignment) { build(:assignment, id: 2, name: 'new_assignment', directory_path: 'new_assignment') }
    let(:new_assignment2) { build(:assignment, id: 2, name: 'new_assignment2', directory_path: 'new_assignment2') }

    context 'when new assignment id fetches successfully' do
      it 'redirects to assignments#edit page' do
        allow(assignment).to receive(:dup).and_return(new_assignment)
        allow(new_assignment).to receive(:save).and_return(true)
        allow(Assignment).to receive(:find).with(2).and_return(new_assignment)
        request_params = { id: 1 }
        get :copy, params: request_params
        expect(flash[:note]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to('/assignments/2/edit')
      end
    end

    context 'when new assignment id does not fetch successfully' do
      it 'shows an error flash message and redirects to assignments#edit page' do
        allow(assignment).to receive(:dup).and_return(new_assignment)
        allow(new_assignment).to receive(:save).and_return(false)
        request_params = { id: 1 }
        get :copy, params: request_params
        expect(flash[:note]).to be_nil
        expect(flash[:error]).to eq('The assignment was not able to be copied. Please check the original assignment for missing information.')
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#delete' do
    context 'when assignment is deleted successfully' do
      it 'shows a success flash message and redirects to tree_display#list page' do
        assignment_form = AssignmentForm.new
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:delete).with('true').and_return(true)
        request_params = {
          id: 1,
          force: 'true'
        }
        user_session = { user: instructor }
        post :delete, params: request_params, session: user_session
        expect(flash[:error]).to be nil
        expect(flash[:success]).to eq('The assignment was successfully deleted.')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when assignment is not deleted successfully' do
      it 'shows an error flash message and redirects to tree_display#list page' do
        assignment_form = AssignmentForm.new
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:delete).with('true').and_raise('You cannot delete this assignment!')
        request_params = {
          id: 1,
          force: 'true'
        }
        user_session = { user: instructor }
        post :delete, params: request_params, session: user_session
        expect(flash[:success]).to be nil
        expect(flash[:error]).to eq('You cannot delete this assignment!')
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#remove_assignment_from_course' do
    context 'when assignment is removed from course successfully' do
      it 'removes assignment and redirects to tree_display#list page' do
        assignment_form = AssignmentForm.new
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:remove_assignment_from_course)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow(assignment).to receive(:save).and_return(true)
        user_session = { user: instructor }
        get :remove_assignment_from_course, params: { id: 1 }
        expect(flash[:error]).to be nil
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#list_submissions' do
    context 'when submissions are listed successfully' do
      it 'gets list of submissions' do
        assignment_form = AssignmentForm.new
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:list_submissions).with('true')
        request_params = {
          id: 1,
          force: 'true'
        }
        user_session = { user: instructor }
        get :list_submissions, params: request_params, session: user_session
        expect(flash[:error]).to be nil
      end
    end
  end
end
