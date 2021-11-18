describe LatePolicy do
  let(:late_policy) {build(:late_policy)}

  # testing positive scenario where same policy name is found for an instructor.
  describe '#check_policy_same_name' do
    it 'finds the policy from the list of late policies' do
      allow(LatePolicy).to receive(:where).with(policy_name: "Dummy Name").and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name("Dummy Name",1)).to eq(true)
    end
  end

  # testing negative scenario where same policy name is not found for an instructor.
  describe '#check_policy_same_name' do
    it 'finds the policy from the list of late policies' do
      allow(LatePolicy).to receive(:where).with(policy_name: "Dummy Name 2").and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name("Dummy Name 2",2)).to eq(false)
    end
  end
end