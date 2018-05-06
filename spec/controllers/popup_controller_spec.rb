describe PopupController do
  let(:team) { build(:assignment_team, id:1, name: "team1", assignment: assignment)}
  let(:student) { build(:student, id: 1, name: "student")}
  let(:student2) { build(:student, id: 2, name: "student2")}
  let(:participant){build(:participant, id:1, user: student, assignment: assignment)}
  let(:participant2){build(:participant, id:2, user: student2, assignment: assignment)}
  let(:response) {build(:response, id: 1)}
  let(:assignment) {build(:assignment, id: 1)}
  let(:response_map){
    build(:review_response_map,
          id: 1,
          reviewee_id: team.id,
          reviewer_id: participant2.id,
          response:[response],
          assignment: assignment)
  }
  final_versions = {:"review round1"=>{:questionnaire_id=>1, :response_ids=>[77024]}, :"review round2"=>{:questionnaire_id=>2, :response_ids=>[]}, :"review round3"=>{:questionnaire_id=>3, :response_ids=>[]}}
  test_url = "http://testurl"
  mocked_comments1 = OpenStruct.new(:comments => "test comment")
  mocked_comments2 = OpenStruct.new( :comments => "test comment2")


  describe '#action_allowed?' do

  end

  describe '#author_feedback_popup' do

  end

  describe '#team_users_popup' do

  end

  describe '#participants_popup' do

  end

  ######### Tone Analysis Tests ##########
  describe "tone analysis tests"do
    before(:each) do
      allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map])
      allow(Assignment).to receive(:find).with('reviewee_id = ?', team.id).and_return(assignment)
      allow(ReviewResponseMap).to receive(:final_versions_from_reviewer).with(1).and_return(final_versions)
      allow(Answer).to receive(:where).with(any_args).and_return(mocked_comments1)
    end
    describe '#tone_analysis_chart_popup' do
      context 'when tone analysis page is loaded, review tone analysis is calculated' do
        it 'builds a tone analysis report for both the summery and tone analysis pages and returns an array of heat map URLs' do
          puts mocked_comments1.comments
          result = get :tone_analysis_chart_popup
          expect(result.to_a[0]).to eq(test_url)
        end
      end
    end

    describe '#view_review_scores_popup' do
      context 'when popup page loads, review tone analysis is calculated' do

      end
    end

    describe '#build_tone_analysis_report' do
      context 'uppon selecting summery, the tone analysis for review comments is calculated and applied to the page' do
        it 'builds a tone analysis report and returns the heat map URLs' do
          result = get :build_tone_analysis_report
          expect(result).to eq(3)
        end
      end
    end

    describe '#build_tone_analysis_heatmap' do
      context 'uppon selecting tone analyis, the tone analysis for each reviewers comments is calculate and displayed' do

      end
    end
  end
  ##########################################

  describe '#reviewer_details_popup' do

  end

  describe '#self_review_popup' do

  end

end
