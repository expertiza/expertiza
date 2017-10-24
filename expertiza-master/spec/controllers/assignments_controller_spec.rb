describe AssignmentsController do
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true,
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm') }
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
      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action'
      end

      context 'when current user is the instructor of current assignment' do
        it 'allows certain action'
      end

      context 'when current user is the ta of the course which current assignment belongs to' do
        it 'allows certain action'
      end

      context 'when current user is a ta but not the ta of the course which current assignment belongs to' do
        it 'does not allow certain action'
      end

      context 'when current user is the instructor of the course which current assignment belongs to' do
        it 'allows certain action'
      end

      context 'when current user is an instructor but not the instructor of current course or current assignment' do
        it 'does not allow certain action'
      end
    end

    context 'when params action is not edit and update' do
      context 'when the role current user is super admin/admin/instractor/ta' do
        it 'allows certain action except edit and update'
      end

      context 'when the role current user is student' do
        it 'does not allow certain action'
      end
    end
  end

  describe '#toggle_access' do
    it 'changes access permissions of one assignment from public to private or vice versa and redirects to tree_display#list page'
  end

  describe '#new' do
    it 'creates a new AssignmentForm object and renders assignment#new page'
  end

  describe '#create' do
    # params = {
    #   assignment_form: {
    #     assignment: {
    #       instructor_id: 2,
    #       course_id: 1,
    #       max_team_size: 1,
    #       id: 1,
    #       name: 'test assignment',
    #       directory_path: '/test',
    #       spec_location: '',
    #       show_teammate_reviews: false,
    #       require_quiz: false,
    #       num_quiz_questions: 0,
    #       staggered_deadline: false,
    #       microtask: false,
    #       reviews_visible_to_all: false,
    #       is_calibrated: false,
    #       availability_flag: true,
    #       reputation_algorithm: 'Lauw',
    #       simicheck: -1,
    #       simicheck_threshold: 100
    #     }
    #   }
    # }
    context 'when assignment_form is saved successfully' do
      it 'redirets to assignment#edit page'
    end

    context 'when assignment_form is not saved successfully' do
      it 'renders assignment#new page'
    end
  end

  describe '#edit' do
    context 'when assignment has staggered deadlines' do
      it 'shows an error flash message and renders edit page'
    end
  end

  describe '#update' do
    context 'when params does not have key :assignment_form' do
      context 'when assignment is saved successfully' do
        it 'shows a note flash message and redirects to tree_display#index page'
      end

      context 'when assignment is not saved successfully' do
        it 'shoes an error flash message and redirects to assignments#edit page'
      end
    end

    context 'when params has key :assignment_form' do
      # params = {
      #   id: 1,
      #   course_id: 1,
      #   assignment_form: {
      #     assignment_questionnaire: [{"assignment_id" => "1", "questionnaire_id" => "666", "dropdown" => "true",
      #                                 "questionnaire_weight" => "100", "notification_limit" => "15", "used_in_round" => "1"}],
      #     assignment: {
      #       instructor_id: 2,
      #       course_id: 1,
      #       max_team_size: 1,
      #       id: 2,
      #       name: 'test assignment',
      #       directory_path: '/test',
      #       spec_location: '',
      #       show_teammate_reviews: false,
      #       require_quiz: false,
      #       num_quiz_questions: 0,
      #       staggered_deadline: false,
      #       microtask: false,
      #       reviews_visible_to_all: false,
      #       is_calibrated: false,
      #       availability_flag: true,
      #       reputation_algorithm: 'Lauw',
      #       simicheck: -1,
      #       simicheck_threshold: 100
      #     }
      #   }
      # }
      context 'when the timezone preference of current user is nil and assignment form updates attributes successfully' do
        it 'shows an error message and redirects to assignments#edit page'
      end

      context 'when the timezone preference of current user is not nil and assignment form updates attributes successfully' do
        it 'shows an error message and redirects to assignments#edit page'
      end
    end
  end

  describe '#show' do
    it 'renders assignments#show page'
  end

  describe '#copy' do
    context 'when new assignment id fetches successfully' do
      it 'redirects to assignments#edit page'
    end

    context 'when new assignment id does not fetch successfully' do
      it 'shows an error flash message and redirects to assignments#edit page'
    end
  end

  describe '#delete' do
    context 'when assignment is deleted successfully' do
      it 'shows a success flash message and redirects to tree_display#list page'
    end

    context 'when assignment is not deleted successfully' do
      it 'shows an error flash message and redirects to tree_display#list page'
    end
  end
end
