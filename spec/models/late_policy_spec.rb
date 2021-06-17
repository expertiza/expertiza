describe LatePolicy do
  let(:participant) { build(:participant, id: 2, grade: 100) }
  let(:assignment) { build(:assignment, id: 1) }
  describe '#check_policy_with_same_name' do
    it 'returns true when there is a policy with the same name' do
   	  lp = LatePolicy.new(policy_name: 'late_policy_1', instructor_id: 6, max_penalty: 5, penalty_per_unit: 5, penalty_unit: 1)
      lp.instructor_id = 6
      list = [lp]
      allow(LatePolicy).to receive(:where).with(policy_name: 'late_policy_1').and_return(list)
      expect(LatePolicy.check_policy_with_same_name('late_policy_1', 6)).to be_truthy 
    end
  end
  describe '#update_calculated_penalty_objects' do
    context 'when it is a submission type penalty' do
      it 'updates the penalty' do
      	lp = LatePolicy.new(policy_name: 'late_policy_1', instructor_id: 6, max_penalty: 5, penalty_per_unit: 5, penalty_unit: 1)
        cp = CalculatedPenalty.create(deadline_type_id: 1, participant_id: 2, penalty_points: nil)
        allow(CalculatedPenalty).to receive(:all).and_return([cp])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:late_policy_id).and_return(3)
        allow(lp).to receive(:id).and_return(3)
        penalties = {submission: 40, review: 30, meta_review: 30}
        allow(LatePolicy).to receive(:calculate_penalty).with(2).and_return(penalties)
        LatePolicy.update_calculated_penalty_objects(lp)
        expect(cp.penalty_points).to eq(40)
      end
    end
    context 'when it is a review type penalty' do
      it 'updates the penalty' do
      	lp = LatePolicy.new(policy_name: 'late_policy_1', instructor_id: 6, max_penalty: 5, penalty_per_unit: 5, penalty_unit: 1)
        cp = CalculatedPenalty.create(deadline_type_id: 2, participant_id: 2, penalty_points: nil)
        allow(CalculatedPenalty).to receive(:all).and_return([cp])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:late_policy_id).and_return(3)
        allow(lp).to receive(:id).and_return(3)
        penalties = {submission: 40, review: 30, meta_review: 30}
        allow(LatePolicy).to receive(:calculate_penalty).with(2).and_return(penalties)
        LatePolicy.update_calculated_penalty_objects(lp)
        expect(cp.penalty_points).to eq(30)
      end
    end
    context 'when it is a metareview type penalty' do
      it 'updates the penalty' do
      	lp = LatePolicy.new(policy_name: 'late_policy_1', instructor_id: 6, max_penalty: 5, penalty_per_unit: 5, penalty_unit: 1)
        cp = CalculatedPenalty.create(deadline_type_id: 5, participant_id: 2, penalty_points: nil)
        allow(CalculatedPenalty).to receive(:all).and_return([cp])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant)
        allow(participant).to receive(:assignment).and_return(assignment)
        allow(assignment).to receive(:late_policy_id).and_return(3)
        allow(lp).to receive(:id).and_return(3)
        penalties = {submission: 40, review: 30, meta_review: 30}
        allow(LatePolicy).to receive(:calculate_penalty).with(2).and_return(penalties)
        LatePolicy.update_calculated_penalty_objects(lp)
        expect(cp.penalty_points).to eq(30)
      end
    end
  end
end