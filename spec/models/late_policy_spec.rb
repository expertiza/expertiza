describe LatePolicy do
  describe '#check_policy_with_same_name' do
    it 'returns true when there is a policy with the same name' do
    	list = [LatePolicy.new(policy_name: 'late_policy_name', instructor_id: 6, max_penalty: 5, penalty_per_unit: 5, penalty_unit: 1)]
    	allow(list).to receive(:present?).and_return(true)
        allow(LatePolicy).to receive(:where).with(policy_name: 'late_policy_name').and_return(list)
        expect(LatePolicy.check_policy_with_same_name('late_policy_name',6)).to be_truthy 
    end
  end
end