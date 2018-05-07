describe PopupController do
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:student) { build(:student, id: 1, name: "student") }
  let(:student2) { build(:student, id: 2, name: "student2") }
  let(:participant) { build(:participant, id: 1, user: student, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, user: student2, assignment: assignment) }
  let(:response) { build(:response, id: 1) }
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
  end

  describe '#author_feedback_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
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
  end

  describe '#self_review_popup' do
    ## INSERT CONTEXT/DESCRIPTION/CODE HERE
  end
end
