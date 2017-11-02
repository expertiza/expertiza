describe ResponseController do
  let(:assignment) { build(:assignment, instructor_id: 6) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
  let(:questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire) }
  let(:answer) { double('Answer') }
  let(:assignment_due_date) { build(:assignment_due_date) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Response).to receive(:find).with('1').and_return(review_response)
    allow(review_response).to receive(:map).and_return(review_response_map)
  end

  describe '#action_allowed?' do
    context 'when params action is edit' do
      context 'when response is not submitted and current_user is the reviewer of the response' do
        it 'allows certain action'
      end

      context 'when response is submitted' do
        it 'does not allow certain action'
      end
    end

    context 'when params action is delete or update' do
      context 'when current_user is the reviewer of the response' do
        it 'allows certain action'
      end
    end

    context 'when params action is view' do
      context 'when response_map is a ReviewResponseMap and current user is the instructor of current assignment' do
        it 'allows certain action'
      end
    end
  end

  describe '#delete' do
    it 'deletes current response and redirects to response#redirection page'
  end

  describe '#edit' do
    it 'renders response#response page'
  end

  describe '#update' do
    context 'when something is wrong during response updating' do
      it 'raise an error and redirects to response#saving page'
    end

    context 'when response is updated successfully' do
      it 'redirects to response#saving page'
    end
  end

  describe '#new' do
    it 'renders response#response page'
  end

  describe '#new_feedback' do
    context 'when current response is nil' do
      it 'redirects to response#new page'
    end

    context 'when current response is not nil' do
      it 'redirects to previous page'
    end
  end

  describe '#view' do
    it 'renders response#view page'
  end

  describe '#create' do
    it 'creates a new response and redirects to response#saving page'
  end

  describe '#saving' do
    it 'save current response map and redirects to response#redirection page'
  end

  describe '#redirection' do
    context 'when params[:return] is feedback' do
      it 'redirects to grades#view_my_scores page'
    end

    context 'when params[:return] is teammate' do
      it 'redirects to student_teams#view page'
    end

    context 'when params[:return] is instructor' do
      it 'redirects to grades#view page'
    end

    context 'when params[:return] is assignment_edit' do
      it 'redirects to assignment#edit page'
    end

    context 'when params[:return] is selfreview' do
      it 'redirects to submitted_content#edit page'
    end

    context 'when params[:return] is survey' do
      it 'redirects to response#pending_surveys page'
    end

    context 'when params[:return] is other content' do
      it 'redirects to student_review#list page'
    end
  end

  describe '#pending_surveys' do
    context 'when session[:user] is nil' do
      it 'redirects to root path (/)'
    end

    context 'when session[:user] is not nil' do
      it 'renders pending_surveys page'
    end
  end
end
