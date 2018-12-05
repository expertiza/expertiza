describe RevisionReviewQuestionnaire do
	let(:participant) { build(:participant) }
	let(:a_team) { build(:assignment_team, id: 1)  }
	let(:rq) { build(:revision_questionnaire) }
	let(:rmaps) { build(:review_response_map) }
	
	describe '#symbol' do
		it 'returns :review' do
			expect(rq.symbol).to eq('review'.to_sym)
		end
	end

	describe '#get_assessments_round_for' do
		context 'participant without team' do
			it 'returns nil' do
			  allow(AssignmentTeam).to receive_messages(:team => nil)
			  expect(rq.get_assessments_round_for(participant)).to be_nil
			end
		end

		context 'nil participant has a team' do
			it "returns an empty list as a nil-participant's team" do
				allow(AssignmentTeam).to receive_messages(:team => a_team)
			  expect(rq.get_assessments_round_for(nil)).to eq([])
			end
		end

		context 'participant with a team' do
			it "gets the participant's responses from the Response Map" do
				responses  = double('responses')
				reviewer = double('reviewer')
				allow(reviewer).to receive_messages(:fullname => 'apple')
				map = double('map')
				allow(map).to receive_messages(:reviewer => reviewer)
				allow(responses).to receive_messages(:select => responses, 
					:map => map, :sort_by => responses)
				a_team = double('a_team')
				allow(a_team).to receive_messages(:id => 1)
				allow(AssignmentTeam).to receive_messages(:team => a_team)
				allow(ResponseMap).to receive_messages(:where => rmaps)
				allow(rmaps).to receive_messages(:reject => rmaps, :flat_map => responses)
				rq.get_assessments_round_for(participant)
			end
		end
	end	
end