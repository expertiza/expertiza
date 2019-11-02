describe LatePolicy do
	let(:policy) do
		LatePolicy.new penalty_per_unit: 10.0, max_penalty: 30, penalty_unit: "Day", times_used: 0, instructor_id: 6, policy_name: 'rspectest'
	end
	#validaes penalty per unit field
	describe 'validate penalty_per_unit' do
		it 'returns the penalty_per_unit' do
			expect(policy.penalty_per_unit).to eq(10.0)
		end

		it 'Validate presence of penalty_per_unit which cannot be blank' do
      			policy.penalty_per_unit = nil
      			expect(policy).not_to be_valid
    		end
		it 'Validate if penalty_per_unit is less than max_penalty' do
      			policy.max_penalty = 20
			policy.penalty_per_unit = 30
      			expect(policy).not_to be_valid
    		end
	end
	
	#validates max_penalty field
	describe 'validate max_penalty' do
		it 'returns the max_penalty' do
			expect(policy.max_penalty).to eq(30)
		end
		it 'Validate presence of max_penalty which cannot be blank' do
      			policy.max_penalty = nil
      			expect(policy).not_to be_valid
    		end
		it 'Validate if max_penalty is less tha 50' do
      			policy.max_penalty = 60
      			expect(policy).not_to be_valid
    		end
	end
	
	#validates penalty unit field
	describe 'validate penalty_unit' do
		it 'returns the penalty_unit' do
			expect(policy.penalty_unit).to eq('Day')
		end
		it 'Validate presence of penalty_unit which cannot be blank' do
      			policy.penalty_unit = nil
      			expect(policy).not_to be_valid
    		end
	end

	describe 'validate times_used backgorund field' do
		it 'returns times_used' do
			expect(policy.times_used).to eq(0)
		end
	end
	
	#validates policy_name field
	describe 'validate policy_name' do
		it 'returns the policy name' do
			expect(policy.policy_name).to eq('rspectest')
		end
		it 'Validate presence of policy name which cannot be blank' do
      			policy.policy_name = nil
      			expect(policy).not_to be_valid
    		end
	end
end
