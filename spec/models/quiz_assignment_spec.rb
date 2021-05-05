describe QuizAssignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, name: 'no one') }
  let(:participant) { build(:participant, id: 1) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  describe '#candidate_topics_for_quiz' do
    context 'when there are no signup topics' do
      it 'returns nil' do
        expect(assignment.candidate_topics_for_quiz).to eq(nil)
      end
    end
  end

end