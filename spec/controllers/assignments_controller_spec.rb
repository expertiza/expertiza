describe AssignmentsController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'same path',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }
  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = {id: '1', action: 'edit'}
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
        controller.params = {id: '1', action: 'new'}
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
      @params = {
        button: '',
        assignment_form: {
          assignment_questionnaire: [{"assignment_id" => "1", "questionnaire_id" => "666", "dropdown" => "true",
                                      "questionnaire_weight" => "100", "notification_limit" => "15", "used_in_round" => "1"}],
          due_date: [{"id" => "", "parent_id" => "", "round" => "1", "deadline_type_id" => "1", "due_at" => "2017/12/05 00:00", "submission_allowed_id" => "3", "review_allowed_id" => "1", "teammate_review_allowed_id" => "3", "review_of_review_allowed_id" => "1", "threshold" => "1"},
                     {"id" => "", "parent_id" => "", "round" => "1", "deadline_type_id" => "2", "due_at" => "2017/12/02 00:00", "submission_allowed_id" => "1", "review_allowed_id" => "3", "teammate_review_allowed_id" => "3", "review_of_review_allowed_id" => "1", "threshold" => "1"}],
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
    end
    context 'when assignment_form is saved successfully' do
      it 'redirects to assignment#edit page' do
        allow(assignment_form).to receive(:assignment).and_return(assignment)
        allow(assignment_form).to receive(:save).and_return(true)
        allow(assignment_form).to receive(:update).with(any_args).and_return(true)
        allow(assignment_form).to receive(:create_assignment_node).and_return(double('node'))
        allow(assignment).to receive(:id).and_return(1)
        allow(Assignment).to receive(:find_by_name).with('test assignment').and_return(assignment)
        allow_any_instance_of(AssignmentsController).to receive(:undo_link)
          .with('Assignment "test assignment" has been created successfully. ').and_return(true)
        post :create, @params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when assignment_form is not saved successfully' do
      it 'renders assignment#new page' do
        allow(assignment_form).to receive(:save).and_return(false)
        post :create, @params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#edit' do
    context 'when assignment has staggered deadlines' do
      it 'shows an error flash message and renders edit page' do
        allow(SignUpTopic).to receive(:where).with(assignment_id: '1').and_return([double('SignUpTopic'), double('SignUpTopic')])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: '1')
          .and_return([double('AssignmentQuestionnaire', questionnaire_id: 666, used_in_round: 1)])
        allow(Questionnaire).to receive(:where).with(id: 666).and_return([double('Questionnaire', type: 'ReviewQuestionnaire')])
        assignment_due_date = build(:assignment_due_date)
        allow(AssignmentDueDate).to receive(:where).with(parent_id: '1').and_return([assignment_due_date])
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        params = {id: 1}
        session = {user: instructor}
        get :edit, params, session
        expect(flash.now[:error]).to eq("You did not specify all the necessary rubrics. You need <b>[AuthorFeedback, TeammateReview] "\
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
          params = {
            id: 1,
            course_id: 1
          }
          session = {user: instructor}
          post :update, params, session
          expect(flash[:note]).to eq('The assignment was successfully saved.')
          expect(response).to redirect_to('/tree_display/list')
        end
      end

      context 'when assignment is not saved successfully' do
        it 'shoes an error flash message and redirects to assignments#edit page' do
          allow(assignment).to receive(:save).and_return(false)
          params = {
            id: 1,
            course_id: 1
          }
          session = {user: instructor}
          post :update, params, session
          expect(flash[:error]).to eq('Failed to save the assignment: ')
          expect(response).to redirect_to('/assignments/1/edit')
        end
      end
    end

    context 'when params has key :assignment_form' do
      before(:each) do
        assignment_questionnaire = double('AssignmentQuestionnaire')
        allow(AssignmentQuestionnaire).to receive(:new).with(any_args).and_return(assignment_questionnaire)
        allow(assignment_questionnaire).to receive(:save).and_return(true)
        @params = {
          id: 1,
          course_id: 1,
          set_pressed: {
            bool: 'true'
          },
          assignment_form: {
            assignment_questionnaire: [{"assignment_id" => "1", "questionnaire_id" => "666", "dropdown" => "true",
                                        "questionnaire_weight" => "100", "notification_limit" => "15", "used_in_round" => "1"}],
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
          session = {user: instructor}
          post :update, @params, session
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to eq("We strongly suggest that instructors specify their preferred timezone to guarantee the correct display time. "\
                                      "For now we assume you are in Eastern Time (US & Canada)")
          expect(response).to redirect_to('/assignments/2/edit')
        end
      end

      context 'when the timezone preference of current user is not nil and assignment form updates attributes successfully' do
        it 'shows an error message and redirects to assignments#edit page' do
          session = {user: instructor}
          post :update, @params, session
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to be nil
          expect(response).to redirect_to('/assignments/2/edit')
        end
      end
    end
  end

  describe '#show' do
    it 'renders assignments#show page' do
      get :show, id: 1
      expect(response).to render_template(:show)
    end
  end

  describe '#copy' do
    let(:new_assignment) { build(:assignment, id: 2, name: 'new assignment', directory_path: 'different path') }
    let(:new_assignment2) { build(:assignment, id: 2, name: 'new assignment', directory_path: 'same path') }

    context 'when new assignment id fetches successfully' do
      it 'redirects to assignments#edit page' do
        allow(assignment).to receive(:dup).and_return(new_assignment)
        allow(new_assignment).to receive(:save).and_return(true)
        allow(Assignment).to receive(:find).with(2).and_return(new_assignment)
        params = {id: 1}
        get :copy, params
        expect(flash[:note]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to('/assignments/2/edit')
      end
    end

    context 'when new assignment directory is same as old' do
      it 'should show an error and redirect to assignments#edit page' do
        allow(AssignmentForm).to receive(:copy).with('1', instructor).and_return(2)
        allow(Assignment).to receive(:find).with(2).and_return(new_assignment2)
        params = {id: 1}
        session = {user: instructor}
        get :copy, params, session
        expect(flash[:note]).to eq("Warning: The submission directory for the copy of this assignment will be the same as the submission directory "\
          "for the existing assignment. This will allow student submissions to one assignment to overwrite submissions to the other assignment. "\
          "If you do not want this to happen, change the submission directory in the new copy of the assignment.")
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to('/assignments/2/edit')
      end
    end

    context 'when new assignment id does not fetch successfully' do
      it 'shows an error flash message and redirects to assignments#edit page' do
        allow(assignment).to receive(:dup).and_return(new_assignment)
        allow(new_assignment).to receive(:save).and_return(false)
        params = {id: 1}
        get :copy, params
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
        params = {
          id: 1,
          force: 'true'
        }
        session = {user: instructor}
        post :delete, params, session
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
        params = {
          id: 1,
          force: 'true'
        }
        session = {user: instructor}
        post :delete, params, session
        expect(flash[:success]).to be nil
        expect(flash[:error]).to eq('You cannot delete this assignment!')
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end
end
