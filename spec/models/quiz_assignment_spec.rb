include QuizAssignment

describe QuizAssignment do

	let(:assignment) { build(:assignment, id: 1)}

	describe '#candidate_topics_for_quiz' do
		context 'when the assignment does not have topics' do
			it 'returns nil' do
				assignment.sign_up_topics = []
				expect(candidate_topics_for_quiz()).to eq(nil)
			end
		end
	end
end