describe LatePolicy do
  let(:late_policy) {build(:late_policy)}
  let(:calculated_penalty) {build(:calculated_penalty)}
  let(:participant) { build(:participant) }

  # testing positive scenario where same policy name is found for an instructor.
  describe '#check_policy_same_name' do
    it 'finds the policy from the list of late policies' do
      allow(LatePolicy).to receive(:where).with(any_args).and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name("Dummy Name",1)).to eq(true)
    end
  end

  # testing negative scenario where same policy name is not found for an instructor.
  describe '#check_policy_same_name' do
    it 'finds the policy from the list of late policies' do
      allow(LatePolicy).to receive(:where).with(any_args).and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name("Dummy Name 2",2)).to eq(false)
    end
  end

  describe '#check_update_calculated_penalty_points' do
    include PenaltyHelper
    it 'gets all calculated penalties' do
      allow(CalculatedPenalty).to receive(:all).and_return(Array(calculated_penalty))
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      # allow_any_instance_of(PenaltyHelper).to receive(:calculated_penalty).and_return({})
      # PenaltyHelper.any_instance.stub!(:calculate_penalty,{submission: 0, review: 0, meta_review: 0})
      # allow(self).to receive(:calculate_penalty).and_return({submission: 0, review: 0, meta_review: 0})
      # expect(LatePolicy.check_policy_with_same_name("Dummy Name 2",2)).to eq(false)
      # @old_penalty = calculated_penalty[:penalty_ponits]
      allow(late_policy).to receive(:calculated_penalty).and_return({})
      LatePolicy.update_calculated_penalty_objects(late_policy)
      # expect(calculated_penalty[:penalty_points]).not_to eq(old_penalty)

    end
  end
end