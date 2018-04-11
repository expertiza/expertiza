describe OnTheFlyCalc do
  describe "#compute total score" do
  end
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }

  describe OnTheFlyCalc do
    let(:assignment1) { create(:assignment,name: "uni1",rounds_of_reviews: 1,teams: [team],participants: [participant])}
    let(:questionnaire) { create(:questionnaire, id: 1)}
    let(:assignment_questionnaire) {create(:assignment_questionnaire, assignment: assignment, used_in_round: 0)}
    let(:assignment2) { create(:assignment,name: "uni2",rounds_of_reviews: 2,teams: [team2], participants: [participant2])}
    let(:assignment_questionnaire2) { create(:assignment_questionnaire, assignment: assignment2, used_in_round: 2, questionnaire: questionnaire)}
    let(:response) {create(:response)}
    let(:response2) {create(:response)}
    let(:response_map) {create(:response_map)}
    let(:response_map2) {create(:response_map)}
    let(:question){create(:question, questionnaire: questionnaire)}
    let(:team){create(:assignment_team, id:1)}
    let(:team2){create(:assignment_team, id:2)}
    let(:participant) {create(:participant, id:1)}
    let(:participant2) {create(:participant, id:2)}
    describe '#compute_total_score' do
      it 'return total scores' do
        @score={"2"=>{:scores=>{:avg=>4.5}}}
        allow(Questionnaire).to receive(:get_weighted_score).with(assignment1,@score).and_return(4.5)
        expect(questionnaire.get_weighted_score(assignment2, @score)).to eq(4.5)
      end
    end
    describe '#compute_reviews_hash' do
      before(:each) do
        allow(Assignment).to receive(:find).with('2').and_return(assignment2)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 2, used_in_round: 2).and_return([assignment_questionnaire2])
        allow(Assignment).to receive(:find).with('1').and_return(assignment1)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 0).and_return([assignment_questionnaire])
      end
      it 'for varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        expect(assignment2.varying_rubrics_by_round?).to eq(true)
        allow(ResponseMap).to receive(:where).with('reviewed_object_id = ? && type = ?', assignment2.id, 'ReviewResponseMap')
      end
      it 'for non-varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(assignment1.varying_rubrics_by_round?).to eq(false)
        allow(ResponseMap).to receive(:where).with('reviewed_object_id = ? && type = ?', assignment1.id, 'ReviewResponseMap')
      end
    end
    describe '#compute_avg_and_ranges_hash' do
      it 'for varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        expect(assignment1.contributors).to eq([team])

      end
      it 'for non-varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        expect(assignment2.contributors).to eq([team2])
      end
    end
    describe '#scores' do
      it 'for varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        expect(Assignment).to receive(:calculate_score)
      end
      it 'for non-varying_rubrics_by_round case' do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(false)
      end
      #allow(ReviewResponseMap).to receive(:get_assessments_for).with(team)
    end

  end
end