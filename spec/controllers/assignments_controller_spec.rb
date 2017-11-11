describe AssignmentsController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true,
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm') }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 10) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }
  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          controller.params = {id: '1', action: "edit"}
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the instructor of current assignment' do
        it 'allows certain action' do
          controller.params = {id: '1', action: "edit"}
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is the ta of the course which current assignment belongs to' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          allow(TaMapping).to receive(:exists?).and_return(true)
          controller.params = {id: '1', action: "update"}
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is a ta but not the ta of the course which current assignment belongs to' do
        it 'does not allow certain action' do
          ta2 = build(:teaching_assistant, id: 4)
          stub_current_user(ta2, ta2.role.name, ta2.role)
          allow(TaMapping).to receive(:exists?).and_return(false)
          controller.params = {id: '1', action: "update"}
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when current user is the instructor of the course which current assignment belongs to' do
        it 'allows certain action' do
          controller.params = {id: '1', action: "edit"}
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when current user is an instructor but not the instructor of current course or current assignment' do
        it 'does not allow certain action' do
          stub_current_user(instructor2, instructor2.role.name, instructor2.role)
          controller.params = {id: '1', action: "edit"}
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is not edit and update' do
      context 'when the role current user is super admin/admin/instractor/ta' do
        it 'allows certain action except edit and update' do
          stub_current_user(ta, ta.role.name, ta.role)
          controller.params = {id: '1', action: "create"}
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role current user is student' do
        it 'does not allow certain action' do
          stub_current_user(student, student.role.name, student.role)
          controller.params = {id: '1', action: "create"}
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  describe '#toggle_access' do
    it 'changes access permissions of one assignment from public to private or vice versa and redirects to tree_display#list page' do
      params = {id: '1'}
      # allow(Assignment).to receive(:find).with('').and_return(assignment)
      # allow(assignment).to receive(:private).and_return(true)
      # allow(assignment).to receive(:save).and_return(true)
      allow(assignment).to receive(:save).and_return(true)
      # get :toggle_access, params: {id: '1'}
      get :toggle_access, params
      # expect(Assignment.count).to eq(1)
      # expect(Assignment.second.private).to be true
      expect(response).to redirect_to '/tree_display/list'
    end
  end

  describe '#new' do
    it 'creates a new AssignmentForm object and renders assignment#new page' do
      # allow(AssignmentForm).to receive(:new).and_return(:assignment_form)
      # allow(:assignment_form).to receive_message_chain(:assignment, :instructor).and_return(:instructor)
      get :new
      expect(assigns(:assignment_form)).to be_kind_of(AssignmentForm)
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    params = {
      assignment_form: {
        assignment: {
          course_id: 1,
          max_team_size: 1,
          instructor_id: 2,
          id: 1,
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
    context 'when assignment_form is saved successfully' do
      it 'redirets to assignment#edit page' do
        # af = double('AssignmentForm', :save => true)
        # allow(assignment_form_params).to
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:save).and_return(true)
        allow(assignment_form).to receive(:create_assignment_node).and_return(true)
        allow_any_instance_of(ApplicationController).to receive(:undo_link).and_return(true)
        allow(assignment_form).to receive(:assignment).and_return(double("Assignment", id: 1, name: "test assignment"))
        post :create, params
        expect(response).to redirect_to edit_assignment_path 1
      end
    end

    context 'when assignment_form is not saved successfully' do
      it 'renders assignment#new page' do
        # allow(AssignmentForm).to receive(:new).and_return(double('AssignmentForm'))
        allow(AssignmentForm).to receive(:new).and_return(assignment_form)
        allow(assignment_form).to receive(:save).and_return(false)
        post :create, params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#edit' do
    context 'when assignment has staggered deadlines' do
      it 'shows an error flash message and renders edit page' do
        allow(SignUpTopic).to receive(:where).with(assignment_id: '1').and_return([
                                                                                    double('SignUpTopic'),
                                                                                    double('SignUpTopic')
                                                                                  ])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: '1').and_return([
                                                                                                double(
                                                                                                  'AssignmentQuestionnaire',
                                                                                                  questionnaire_id: 666,
                                                                                                  used_in_round: 1
                                                                                                )
                                                                                              ])
        assignment_due_date = build(:assignment_due_date)
        allow(AssignmentDueDate).to receive(:where).with(parent_id: '1').and_return([assignment_due_date])
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        allow(Questionnaire).to receive(:where).with(id: 666).and_return([double('Questionnaire', type: 'ReviewQuestionnaire')])
        params = {id: 1}
        get :edit, params
        expect(flash.now[:error]).to eq("You did not specify all the necessary rubrics. \
You need <b>[AuthorFeedback, TeammateReview] </b> of assignment <b>test assignment</b> before saving the assignment. \
You can assign rubrics <a id='go_to_tabs2' style='color: blue;'>here</a>.")
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#update' do
    context 'when params does not have key :assignment_form' do
      context 'when assignment is saved successfully' do
        it 'shows a note flash message and redirects to tree_display#index page' do
          allow(Assignment).to receive(:find).with(id: '1').and_return(:assignment)
          allow(assignment).to receive(:save).and_return(true)
          params = {id: 1, course_id: 1}
          post :update, params
          expect(flash[:note]).to eq("The assignment was successfully saved.")
          expect(response).to redirect_to list_tree_display_index_path
        end
      end

      context 'when assignment is not saved successfully' do
        it 'shoes an error flash message and redirects to assignments#edit page' do
          allow(Assignment).to receive(:find).with(id: '1').and_return(:assignment)
          allow(assignment).to receive(:save).and_return(false)
          allow(assignment).to receive_message_chain(:errors, :full_messages) { ['Assignment not find.', 'Course not find.'] }
          params = {id: 1, course_id: 1}
          post :update, params
          expect(flash[:error]).to eq("Failed to save the assignment: Assignment not find. Course not find.")
          expect(response).to redirect_to edit_assignment_path assignment.id
        end
      end
    end

    context 'when params has key :assignment_form' do
      params = {
        id: 1,
        course_id: 1,
        assignment_form: {
          assignment_questionnaire: [{"assignment_id" => "2", "questionnaire_id" => "666", "dropdown" => "true",
                                      "questionnaire_weight" => "100", "notification_limit" => "15", "used_in_round" => "1"}],
          assignment: {
            instructor_id: 3,
            course_id: 2,
            max_team_size: 2,
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
      context 'when the timezone preference of current user is nil and assignment form updates attributes successfully' do
        it 'shows an error message and redirects to assignments#edit page' do
          # admin2 = double(:admin, timezonepref: nil, )
          stub_current_user(admin, admin.role.name, admin.role)
          # asg = double('Assignment', instructor_id: 6, instructor: instructor)
          # asg_form = double('AssignmentForm', id: 0, assignment: asg)
          # allow(asg_form).to receive(:update_attributes).and_return(true)
          # allow(AssignmentForm).to receive(:create_form_object).and_return(asg_form)
          allow(AssignmentQuestionnaire).to receive(:where).and_return([double('AssignmentQuestionnaire', questionnaire_id: 666, used_in_round: 1)])
          allow_any_instance_of(AssignmentForm).to receive(:update_assignment_questionnaires).and_return(true)
          # usr = double('User', timezonepref: nil, parent_id: 1)
          parent = double('User')
          allow(parent).to receive(:timezonepref).and_return("UTC")
          allow(User).to receive(:find).and_return(parent)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
          allow(assignment_form).to receive_message_chain(assignment, instructor).with(admin)
          allow(assignment_form).to receive(:update_attributes).and_return(true)
          allow(assignment_form).to receive(:assignment).and_return(double("Assignment", id: 2, name: "test assignment"))
          post :update, params
          expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to eq("We strongly suggest that instructors specify their preferred \
timezone to guarantee the correct display time. For now we assume you are in UTC")
          expect(response).to redirect_to edit_assignment_path assignment_form.assignment.id
        end
      end

      context 'when the timezone preference of current user is not nil and assignment form updates attributes not successfully' do
        it 'shows an error message and redirects to assignments#edit page' do
          admin = build(:admin, timezonepref: 'Eastern Time (US & Canada)')
          stub_current_user(admin, admin.role.name, admin.role)
          allow(AssignmentQuestionnaire).to receive(:where).and_return([double('AssignmentQuestionnaire', questionnaire_id: 666, used_in_round: 1)])
          allow_any_instance_of(AssignmentForm).to receive(:update_assignment_questionnaires).and_return(true)
          # allow_any_instance_of(AssignmentForm).to receive(:create_form_object).and_return(assignment_form)
          parent = double('User')
          allow(parent).to receive(:timezonepref).and_return("UTC")
          allow(User).to receive(:find).and_return(parent)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
          allow(assignment_form).to receive_message_chain(assignment, instructor).with(admin)
          allow_any_instance_of(AssignmentForm).to receive(:update_attributes).and_return(false)
          allow(assignment_form).to receive(:assignment).and_return(double("Assignment", id: 1, name: "test assignment"))
          allow_any_instance_of(AssignmentForm).to receive_message_chain(:errors, :get) { 'Assignment not find. Course not find.' }
          post :update, params
          # expect(flash[:note]).to eq('The assignment was successfully saved....')
          expect(flash[:error]).to eq("Failed to save the assignment: Assignment not find. Course not find.")
          expect(response).to redirect_to edit_assignment_path assignment_form.assignment.id
        end
      end
    end
  end

  describe '#show' do
    it 'renders assignments#show page' do
      allow(Assignment).to receive(:find).and_return(:assignment)
      get :show
      expect(response).to render_template(:show)
    end
  end

  describe '#copy' do
    context 'when new assignment id fetches successfully' do
      it 'redirects to assignments#edit page' do
        allow(ApplicationController).to receive(:current_user).and_return(:student)
        asg = double('Assignment', id: 1, directory_path: 1)
        allow(Assignment).to receive(:find).and_return(asg)
        allow(AssignmentForm).to receive(:copy).and_return(asg.id)
        params = {id: 1}
        get :copy, params
        expect(response).to redirect_to edit_assignment_path assignment.id
      end
    end

    context 'when new assignment id does not fetch successfully' do
      it 'shows an error flash message and redirects to assignments#edit page' do
        allow(ApplicationController).to receive(:current_user).and_return(:student)
        allow(Assignment).to receive(:find).and_return(:assignment)
        allow(AssignmentForm).to receive(:copy).and_return(nil)
        params = {id: 1}
        get :copy, params
        expect(flash[:error]).to eq('The assignment was not able to be copied. Please check the original assignment for missing information.')
        expect(response).to redirect_to list_tree_display_index_path
      end
    end
  end

  describe '#delete' do
    context 'when assignment is deleted successfully' do
      it 'shows a success flash message and redirects to tree_display#list page' do
        asg = double('Assignment', instructor_id: 6)
        asg_form = double('AssignmentForm', id: 0, assignment: asg)
        allow(asg_form).to receive(:delete)
        allow(AssignmentForm).to receive(:create_form_object).and_return(asg_form)
        session[:user] = double('User', get_instructor: 6)
        params = {id: 0, force: true}
        get :delete, params
        expect(flash[:success]).to eq("The assignment was successfully deleted.")
        expect(response).to redirect_to list_tree_display_index_path
      end
    end

    context 'when assignment is not deleted successfully' do
      it 'shows an error flash message and redirects to tree_display#list page' do
        asg = double('Assignmnet', instructor_id: 0)
        asg_form = double('AssignmentForm', id: 0, assignment: asg)
        allow(AssignmentForm).to receive(:create_form_object).and_return(asg_form)
        session[:user] = double('User', get_instructor: 1)
        params = {id: 0}
        get :delete, params
        expect(flash[:error]).to eq("You are not authorized to delete this assignment.")
        expect(response).to redirect_to list_tree_display_index_path
      end
    end
  end
end
