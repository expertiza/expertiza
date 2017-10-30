describe GradesController do
  let(:review_response) { build(:response) }
  let(:admin) { build(:admin) }
  let(:question) { build(:question) }
  let(:student) { build(:student) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:review_questionnaire_team) { create(:questionnaire, id: 177, questions: [question], name: 'rspec_test') }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_team) { create(:assignment, id: 638, questionnaires: [review_questionnaire_team], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment_team, user_id: 1) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }

  before(:each) do
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(participant).to receive(:team).and_return(team)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
  end

  describe '#view' do
    before do
      @assignment = build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true)
    end
    context 'when current assignment varys rubric by round' do
      it 'retrieves questions, calculates scores and renders grades#view page' do
        allow(AssignmentQuestionnaire).to receive(:where).and_return([assignment_questionnaire])
        get :view, id: 1
        expect(response).to render_template(:view)
      end
    end

    context 'when current assignment does not vary rubric by round' do
      it 'calculates scores and renders grades#view page' do
        allow(@assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        get :view, id: 1
        expect(response).to render_template(:view)
      end
    end
  end

  describe '#view_my_scores' do
    before(:each) do
      @participant = build(:participant, id: 1, assignment: assignment, user_id: 1)
      allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(Participant).to receive(:find).with('1').and_return(participant)
    end
    context 'when view_my_scores page is not allow to access' do
      it 'shows a flash error message and redirects to root path (/)' do
        get :view_my_scores, { id: 1 }
        receive(:redirect_when_disallowed).and_return(true)
        expect(flash[:error]).to eq('You are not on the team that wrote this feedback')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when view_my_scores page is allow to access' do
      it 'renders grades#view_my_scores page' do
        # @participant.assignment.max_team_size = 1
        # allow(TeamsUser).to receive(:team_id).with(1, 1).and_return([1])
        # receive(:redirect_when_disallowed).and_return(false)
        #
        # allow(@participant).to receive(:scores).with(@questions).and_return([100])
        # allow(SignedUpTeam).to receive(:topic_id).with(1, 1).and_return([1])
        # allow(assignment).to receive(:get_current_stage).with(1).and_return([1])

        # get :view_my_scores, { id: '1' }
        # expect(response).to render_template(:view_my_scores)
      end
    end
  end

  describe '#view_team' do
    it 'renders grades#view_team page' do
      @participant = participant
      @assignment = assignment
      puts "hello"
      puts @participant.id
      puts @assignment.questionnaires.where type: 'ReviewQuestionnaire'

      get :view_team, { id: @participant.id }
      expect(response).to render_template(:view_team)
    end
  end

  describe '#edit' do
    it 'renders grades#edit page' do
      @participant = build(:participant, id: 1, assignment: assignment, user_id: 1)
      @assignment = build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true)
      @questions = build(:question)
      allow(AssignmentQuestionnaire).to receive(:find_by).and_return(assignment_questionnaire)
      get :edit, { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe '#instructor_review' do
    before(:each) do
      allow(AssignmentParticipant).to receive(:find).with('6').and_return(instructor)
      allow(AssignmentParticipant).to receive(:find_or_create_by).with(1, 1).and_return(participant)
      allow(reviewer).to receive(:new_record?).and_return(false)
      allow(ReviewResponseMap).to receive(:find_or_create_by).with(1, 1).and_return(review_response_map)
      get :instructor_review, { id: 6 }
    end
    context 'when review does not exist' do
      # it 'redirects to grades#new page' do
      #   allow(review_mapping).to receive(:new_record?).and_return(true)
      #   expect(response).to redirect_to(controller: 'response', action: 'new', id: review_mapping.map_id, return: "instructor")
      # end
    end

    context 'when review exists' do
    #   it 'redirects to grades#edit page' do
    #     allow(review_mapping).to receive(:new_record?).and_return(false)
    #     allow(Response).to receive(:find_by).and_return(review_response)
    #     expect(response).to redirect_to(controller: 'response', action: 'edit', id: review.id, return: "instructor")
    #   end
    end
  end

  describe '#update' do
    before(:each) do
      allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
      @participant = participant
      @assignment = build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true)
      @questions = build(:question)
      allow(AssignmentQuestionnaire).to receive(:find_by).and_return(assignment_questionnaire)
    end
    context 'when total is not equal to participant\'s grade' do
      it 'updates grades and redirects to grades#edit page' do
        controller.params[:total_score] = 100
        controller.params[:participant] = {}
        controller.params[:participant][:grade] = 90
        # patch :update, {id: 1, total_score: @participant.scores(@questions)[:total_score], participant: participant, grade: participant.grade}
        # expect(participant.grade).to eql total_score
        # expect(response).to redirect_to(:edit)
      end
    end

    context 'when total is equal to participant\'s grade' do
      it 'redirects to grades#edit page' do
        # participant.grade = 100
        # total_score = 100
        # expect(response).to be_success
      end
    end
  end

  describe '#save_grade_and_comment_for_submission' do
    it 'saves grade and comment for submission and redirects to assignments#list_submissions page' do
    end
  end
end
