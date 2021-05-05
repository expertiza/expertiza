describe QuizAssignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, name: 'no one') }
  let(:participant) { build(:participant, id: 1) }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:quiz_response_map1) { build(:quiz_response_map, id: 1) }
  let(:quiz_response_map2) { build(:quiz_response_map, id: 2) }
  describe '#candidate_topics_for_quiz' do
    context 'when there are no signup topics' do
      it 'returns nil' do
        expect(assignment.candidate_topics_for_quiz).to eq(nil)
      end
    end
  end
  describe '#quiz_taken_by?' do
  	context 'when the participant has taken 2 quizzes' do
      it 'returns true' do
        allow(QuizQuestionnaire).to receive(:find_by).with(instructor_id: 6).and_return(questionnaire1)
        allow(QuizResponseMap).to receive(:where).with('reviewee_id = 6 AND reviewer_id = 1 AND reviewed_object_id = 1').and_return([quiz_response_map1, quiz_response_map2])
        expect(assignment.quiz_taken_by?(instructor, participant)).to eq(true)
      end
    end 
  end

end