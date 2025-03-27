describe QuizResponseMap do
  let(:quiz_questionnaire) { QuizQuestionnaire.new }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:quiz_response_map) { build(:quiz_response_map, quiz_questionnaire: quiz_questionnaire, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:response) { build(:response, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:score) { double }
  describe '#questionnaire' do
    it 'returns the questionnaire' do
      expect(quiz_response_map.questionnaire).to eq(quiz_questionnaire)
    end
  end
  describe '#get_title' do
    it 'returns the name of responses it holds' do
      expect(quiz_response_map.get_title).to eq('Quiz')
    end
  end
  describe '#delete' do
    it 'deletes the map and associated responses' do
      expect(quiz_response_map.delete).to eq(quiz_response_map)
    end
  end
  describe '#mapping_for_reviewer' do
    it 'returns quiz response maps where the reviewer is the participant' do
      allow(QuizResponseMap).to receive(:where).and_return([quiz_response_map])
      expect(QuizResponseMap.mappings_for_reviewer(participant.id)).to eq([quiz_response_map])
    end
  end
  describe '#quiz_score' do
    context 'when the quiz has not been taken' do
      it 'returns N/A' do
        allow(quiz_response_map).to receive(:response).and_return(nil)
        expect(quiz_response_map.quiz_score).to eq('N/A')
      end
    end
    context 'when the score has not been calculated' do
      it 'returns N/A' do
        allow(quiz_response_map).to receive(:response).and_return([response])
        allow(ScoreView).to receive(:find_by_sql).and_return(nil)
        expect(quiz_response_map.quiz_score).to eq('N/A')
      end
    end
    context 'when the score has been calculated' do
      it 'returns the score rounded' do
        allow(quiz_response_map).to receive(:response).and_return([response])
        calculated_score = double('Calculated Score')
        calculated_scores = [calculated_score]
        allow(ScoreView).to receive(:find_by_sql).and_return(calculated_scores)
        allow(calculated_score).to receive(:graded_percent).and_return(97)
        expect(quiz_response_map.quiz_score).to eq(97)
      end
    end
  end

  describe '.create_quiz_assignment' do
    context 'when participant is not found' do
      it 'raises an error' do
        allow(AssignmentParticipant).to receive(:find_by).and_return(nil)
        expect {
          QuizResponseMap.create_quiz_assignment(1, 1, 1)
        }.to raise_error('Participant not found')
      end
    end

    context 'when participant has already taken the quiz' do
      it 'raises an error' do
        allow(QuizResponseMap).to receive(:exists?).and_return(true)
        expect {
          QuizResponseMap.create_quiz_assignment(1, 1, 1)
        }.to raise_error('Already taken this quiz')
      end
    end

    context 'when quiz assignment is successfully created' do
      it 'creates a new quiz response map' do
        allow(AssignmentParticipant).to receive(:find_by).and_return(participant)
        allow(QuizResponseMap).to receive(:exists?).and_return(false)
        allow(Questionnaire).to receive(:find).and_return(questionnaire)
        allow(QuizResponseMap).to receive(:create!).and_return(true)
        expect(QuizResponseMap.create_quiz_assignment(1, 1, 1)).to be_truthy
      end
    end
  end

  describe '#unique_quiz_assignment' do
    it 'adds an error if the quiz assignment already exists' do
      allow(QuizResponseMap).to receive(:exists?).and_return(true)
      quiz_response_map = QuizResponseMap.new(reviewer_id: 1, reviewed_object_id: 1)
      quiz_response_map.valid?
      expect(quiz_response_map.errors[:base]).to include('You have already taken this quiz')
    end
  end
end
