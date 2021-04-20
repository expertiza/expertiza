describe QuizAssignment do

	let(:assignment) { build(:assignment, id: 1)}

	describe '#candidate_topics_for_quiz' do
		context 'when the assignment does not have topics' do
			it 'returns nil' do
				allow(assignment).to receive(:sign_up_topics).and_return([])
				expect(candidate_topics_for_quiz()).to eq(nil)
			end
		end
	end
end