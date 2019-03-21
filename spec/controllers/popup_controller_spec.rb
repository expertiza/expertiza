describe PopupController do
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:student) { build(:student, id: 1, name: "student") }
  let(:student2) { build(:student, id: 2, name: "student2") }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor) }
  let(:ta) { build(:teaching_assistant) }
  let(:participant) { build(:participant, id: 1, user_id: 1, user: student, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }

  let(:response) { build(:response, id: 1) }
  let(:questionnaire) { build(:questionnaire, id: 1, max_question_score: 15)}
  let(:question) { build(:question, id: 1, questionnaire_id: questionnaire.id)}
  let(:answer) { build(:answer, id: 1, question_id: question.id, response_id: response.id) }

  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map) { build(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  final_versions = {
    review_round_one: {questionnaire_id: 1, response_ids: [77024]},
    review_round_two: {questionnaire_id: 2, response_ids: []},
    review_round_three: {questionnaire_id: 3, response_ids: []}
  }


  test_url = "http://peerlogic.csc.ncsu.edu/reviewsentiment/viz/478-5hf542"
  mocked_comments_one = OpenStruct.new(comments: "test comment")

  describe '#action_allowed?' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
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
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
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
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end

  describe '#participants_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end

  ######### Tone Analysis Tests ##########
  describe "tone analysis tests" do
    before(:each) do
      allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map])
      allow(Assignment).to receive(:find).with('reviewee_id = ?', team.id).and_return(assignment)
      allow(ReviewResponseMap).to receive(:final_versions_from_reviewer).with(1).and_return(final_versions)
      allow(Answer).to receive(:where).with(any_args).and_return(mocked_comments_one)
      @request.host = test_url
    end
    describe '#tone_analysis_chart_popup' do
      context 'when tone analysis page is loaded, review tone analysis is calculated' do
        it 'builds a tone analysis report for both the summery and tone analysis pages and returns an array of heat map URLs' do
          result = get :tone_analysis_chart_popup
          expect(result["Location"]).to eq(test_url + "/") ## Placeholder URL should be returned since GET returns a 302 status redirection error
        end
      end
    end

    describe '#view_review_scores_popup' do
      ## INSERT CONTEXT/DESCRIPTION/CODE HERE
    end

    describe '#build_tone_analysis_report' do
      context 'upon selecting summery, the tone analysis for review comments is calculated and applied to the page' do
        it 'builds a tone analysis report and returns the heat map URLs' do
          result = get :build_tone_analysis_report
          expect(result["Location"]).to eq(test_url + "/") ## Placeholder URL should be returned since GET returns a 302 status redirection error
        end
      end
    end

    describe '#build_tone_analysis_heatmap' do
      ## INSERT CONTEXT/DESCRIPTION/CODE HERE
    end
  end
  ##########################################

  describe '#reviewer_details_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
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
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
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
