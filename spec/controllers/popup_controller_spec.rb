describe PopupController do
  let(:assignment_team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
#   let(:team) { build(:team) }
  let(:team_user) { build(:team_user) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:student) { build(:student, id: 1, name: "student") }
  let(:student2) { build(:student, id: 2, name: "student2") }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor) }
  let(:ta) { build(:teaching_assistant) }
  let(:participant) { build(:participant, id: 1, user_id: 1, user: student, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }
  let(:response) { build(:response, id: 1) }
  let(:questionnaire) { build(:questionnaire, id: 1, max_question_score: 15) }
  let(:question) { build(:question, id: 1, questionnaire_id: questionnaire.id) }
  let(:answer) { build(:answer, id: 1, question_id: question.id, response_id: response.id, answer: 10) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map) { build(:review_response_map, id: 1, reviewee_id: assignment_team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  let(:final_versions) { { review_round_one:{ questionnaire_id: 1, response_ids: [1] },
      review_round_two: { questionnaire_id: 2, response_ids: [2] },
      review_round_three: { questionnaire_id: 3, response_ids: [3] }
  } }
  test_url = "http://peerlogic.csc.ncsu.edu/reviewsentiment/viz/478-5hf542"
  mocked_comments_one = OpenStruct.new(comments: "test comment")
  let(:sentiment_summary) {[{"sentiments"=>[{ "id" => 0, "neg" => "0.00", "neu" => "1.00", "pos" => "0.00", "sentiment" => "0.00", "text" => "N/A" }]}]}

  describe '#action_allowed?' do
    context 'when the role name of current user is super admin or admin' do
      it 'allows certain action' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'when the role current user is super instructor' do
      it 'allows certain action' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'when the role current user is ta' do
      it 'allows certain action' do
        stub_current_user(ta, ta.role.name, ta.role)
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

  describe '#author_feedback_popup' do
    context 'when response_id exists' do
      it 'get the result' do
        params = {response_id: 1, reviewee_id: 1}
        session = {user: instructor}
        allow(Answer).to receive(:where).with(any_args).and_return([answer])
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
        allow(Response).to receive(:find).with(any_args).and_return(response)
        allow(response).to receive(:average_score).and_return(80)
        allow(response).to receive(:total_score).and_return(100)
        allow(response).to receive(:maximum_score).and_return(90)
        get :author_feedback_popup, params, session
        expect(controller.instance_variable_get(:@total_percentage)).to eq 80
        expect(controller.instance_variable_get(:@total_possible)).to eq 90
        expect(controller.instance_variable_get(:@sum)).to eq 100
      end
    end
  end

  describe '#team_users_popup' do
    before(:each) do
      allow(Team).to receive(:find).with("1").and_return(team)
      allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
      allow(TeamsUser).to receive(:where).with(any_args).and_return(team_user)
    end

    context 'when a response map exists' do
      it 'calculates response stats for one response' do
        session = {user: instructor}
        params = {id: 1, id2: 1}
        allow(ResponseMap).to receive(:where).with("1").and_return(response_map)
        allow(assignment).to receive(:num_review_rounds).and_return(1)
        allow(Answer).to receive(:where).with(any_args).and_return([answer])
        allow(Response).to receive(:where).with(any_args).and_return([response])
        allow(Response).to receive(:find).with(any_args).and_return(response)
        allow(response).to receive(:questionnaire_by_answer).with(any_args).and_return(questionnaire)
        allow(response).to receive(:average_score).and_return(90)
        allow(response).to receive(:total_score).and_return(90)
        allow(response).to receive(:maximum_score).and_return(100)
        get :team_users_popup, params, session
        expect(controller.instance_variable_get(:@response_round_1)).to eq response
        expect(controller.instance_variable_get(:@response_id_round_1)).to eq 1
        expect(controller.instance_variable_get(:@scores_round_1)).to eq [answer]
        expect(controller.instance_variable_get(:@max_score_round_1)).to eq questionnaire.max_question_score
        expect(controller.instance_variable_get(:@total_percentage_round_1)).to eq 90
        expect(controller.instance_variable_get(:@sum_round_1)).to eq 90
        expect(controller.instance_variable_get(:@total_possible_round_1)).to eq 100
      end
    end
    context 'when a response map does not exist' do
      it 'finds team and users' do
        session = {user: instructor}
        params = {id: 1}

        get :team_users_popup, params, session
        expect(controller.instance_variable_get(:@team)).to eq team
        expect(controller.instance_variable_get(:@assignment)).to eq assignment
        expect(controller.instance_variable_get(:@team_users)).to eq team_user
      end
    end
  end

  describe '#participants_popup' do
    describe 'called with no response' do
      it 'does not calculate scores' do
        params = {id: 1}
        session = {user: instructor}
        allow(Participant).to receive(:find).with("1").and_return(participant)
        allow(participant).to receive(:parent_id).and_return(1)
        allow(User).to receive(:find).with(any_args).and_return(instructor)
        get :participants_popup, params, session
        expect(controller.instance_variable_get(:@sum)).to eq 0
        expect(controller.instance_variable_get(:@count)).to eq 0
        expect(controller.instance_variable_get(:@temp)).to eq 0
        expect(controller.instance_variable_get(:@maxscore)).to eq 0
        expect(controller.instance_variable_get(:@participantid)).to eq "1"
        expect(controller.instance_variable_get(:@uid)).to eq 1
        expect(controller.instance_variable_get(:@assignment_id)).to eq 1
        expect(controller.instance_variable_get(:@user)).to eq instructor
        expect(controller.instance_variable_get(:@myuser)).to eq instructor.id
        expect(controller.instance_variable_get(:@scores)).to be nil
      end

    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
      it "renders the page successfuly as Instructor" do 
        allow(Team).to receive(:find).and_return(team)
        allow(Assignment).to receive(:find).and_return(assignment)
        params = {id: team.id, assignment: assignment, reviewer_id: participant2.id}
        session = {user: instructor}
        result = get :team_users_popup, params, session
        expect(result.status).to eq 200
      end
    end

    describe 'called with a response' do
      before(:each) do
        allow(Participant).to receive(:find).with(any_args).and_return(participant)
        allow(participant).to receive(:parent_id).and_return(1)
        allow(Participant).to receive(:where).with(any_args).and_return(participant)
        allow(User).to receive(:find).with(any_args).and_return(instructor)
        allow(Response).to receive(:find_by).with(any_args).and_return(response)
        allow(ResponseMap).to receive(:find).with(any_args).and_return(response_map)
        allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
      end
      context 'assignment has no review questionnaire' do
        it 'calculates the scores without a max' do
          params = {id: 1, id2: 1}
          session = {user: instructor}
          allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([])
          allow(Answer).to receive(:where).with(any_args).and_return([answer])
          get :participants_popup, params, session
          expect(controller.instance_variable_get(:@maxscore)).to eq 0
          expect(controller.instance_variable_get(:@reviewid)).to eq response_map.id
          expect(controller.instance_variable_get(:@pid)).to eq response_map.reviewer_id
          expect(controller.instance_variable_get(:@reviewer_id)).to eq participant.user_id
          expect(controller.instance_variable_get(:@assignment_id)).to eq response_map.reviewed_object_id
          expect(controller.instance_variable_get(:@assignment)).to eq assignment
          expect(controller.instance_variable_get(:@participant)).to eq participant
          expect(controller.instance_variable_get(:@revquids)).to be nil
          expect(controller.instance_variable_get(:@temp)).to eq 10
          expect(controller.instance_variable_get(:@sum)).to eq 10
          expect(controller.instance_variable_get(:@count)).to eq 1
        end
      end

      context 'assignment has a review questionnaire' do
        it 'calculates the scores with a max' do
          params = {id: 1, id2: 1}
          session = {user: instructor}
          allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([questionnaire])
          allow(Answer).to receive(:where).with(any_args).and_return([answer])
          allow(questionnaire).to receive(:questionnaire_id).and_return(1)
          allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
          get :participants_popup, params, session
          expect(controller.instance_variable_get(:@maxscore)).to eq 15
          expect(controller.instance_variable_get(:@revqids)).to eq [questionnaire]
          expect(controller.instance_variable_get(:@review_questionnaire)).to eq questionnaire
          expect(controller.instance_variable_get(:@review_questions)).to be
          expect(controller.instance_variable_get(:@sum1)).to be 1000.0/15.0
        end
      end
    end
  end
  ######### Tone Analysis Tests ##########
  describe "tone analysis tests" do
    before(:each) do
      allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', assignment_team.id).and_return([response_map])
      allow(Assignment).to receive(:find).with('reviewee_id = ?', assignment_team.id).and_return(assignment)
      allow(ReviewResponseMap).to receive(:final_versions_from_reviewer).with("1").and_return(final_versions)
      allow(Answer).to receive(:where).with(any_args).and_return(mocked_comments_one)
      @request.host = test_url
      allow(Questionnaire).to receive(:find).with(any_args).and_return(questionnaire)
      allow(Question).to receive(:where).with(:questionnaire_id => questionnaire.id).and_return([question])
    end

    describe '#tone_analysis_chart_popup' do
      context 'review tone analysis is calculated' do
        it 'prepares tone analysis report for building' do
          params = {reviewer_id: 1, assignment_id: 1}
          session = {user: instructor}
          get :tone_analysis_chart_popup, params, session
          expect(controller.instance_variable_get(:@reviewer_id)).to eq "1"
          expect(controller.instance_variable_get(:@assignment_id)).to eq "1"
          expect(controller.instance_variable_get(:@review_final_versions)).to eq final_versions
        end
      end
    end

    describe '#view_review_scores_popup' do
      context 'review tone analysis is calculated' do
        it 'prepares tone analysis report for building' do
          params = {reviewer_id: 1, assignment_id: 1}
          session = {user: instructor}
          get :view_review_scores_popup, params, session
          expect(controller.instance_variable_get(:@reviewer_id)).to eq "1"
          expect(controller.instance_variable_get(:@assignment_id)).to eq "1"
          expect(controller.instance_variable_get(:@review_final_versions)).to eq final_versions
          expect(controller.instance_variable_get(:@reviews)).to eq []
        end
      end
    end
  end

  describe '#build_tone_analysis_report' do
    before(:each) do
      allow(Questionnaire).to receive(:find).with(any_args).and_return(questionnaire)
      allow(Question).to receive(:where).with(:questionnaire_id => questionnaire.id).and_return([question])
    end
    describe 'answer is not provided' do
       it 'build tone analysis report' do
         controller.instance_variable_set(:@review_final_versions, final_versions)
          allow(Answer).to receive(:where).with(any_args).and_return([])
         controller.send(:build_tone_analysis_report)
       end
     end

    describe 'answer is provided' do
       it 'build tone analysis report' do
         controller.instance_variable_set(:@review_final_versions, final_versions)
          allow(Answer).to receive(:where).with(any_args).and_return([answer])
         controller.send(:build_tone_analysis_report)
       end
    end
  end

  describe '#build_tone_analysis_heatmap' do
    describe 'sentiment is empty' do
      before(:each) do
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', assignment_team.id).and_return([response_map])
        allow(Assignment).to receive(:find).with('reviewee_id = ?', assignment_team.id).and_return(assignment)
        allow(ReviewResponseMap).to receive(:final_versions_from_reviewer).with("1").and_return(final_versions)
        allow(Questionnaire).to receive(:find).with(any_args).and_return(questionnaire)
        allow(Question).to receive(:where).with(:questionnaire_id => questionnaire).and_return([question])
        controller.instance_variable_set(:@review_final_versions, final_versions)
        controller.instance_variable_set(:@sentiment_summary, sentiment_summary)
        controller.send(:build_tone_analysis_heatmap)
      end
      it 'build tone analysis heatmap' do
      end
    end
  end

  describe '#reviewer_details_popup' do
    context 'it will show the reviewer details' do
      it 'it will show the reviewer details' do
        params = {assignment_id: 1, id: 1}
        allow(Participant).to receive(:find).with(any_args).and_return(participant)
        allow(User).to receive(:find).with(1).and_return(1)
        session = {user: instructor}
        get :reviewer_details_popup, params, session
        expect(controller.instance_variable_get(:@id)).to eq "1"
      end
    end
  end

  describe '#self_review_popup' do
    context 'when response_id exists' do
      it 'get the result' do
        params = {response_id: 1, user_fullname: 1}
        session = {user: instructor}
        allow(Answer).to receive(:where).with(any_args).and_return([answer])
        allow(Question).to receive(:find).with(1).and_return(question)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
        allow(Response).to receive(:find).with(any_args).and_return(response)
        allow(response).to receive(:average_score).and_return(80)
        allow(response).to receive(:total_score).and_return(100)
        allow(response).to receive(:maximum_score).and_return(90)
        get :self_review_popup, params, session
        expect(controller.instance_variable_get(:@total_percentage)).to eq 80
        expect(controller.instance_variable_get(:@total_possible)).to eq 90
        expect(controller.instance_variable_get(:@sum)).to eq 100
      end
    end
  end
end
