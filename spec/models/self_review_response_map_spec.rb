describe SelfReviewResponseMap do
  let(:assignment) { build(:assignment, id: 1) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let(:assignment_questionnaire2) { build(:assignment_questionnaire, id: 2, assignment_id: 1, questionnaire_id: 2) }
  let(:questionnaire1) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, type: 'MetareviewQuestionnaire') }
  let(:self_review_response_map) { build(:self_review_response_map, assignment: assignment) }
  let(:next_due_date) { build(:assignment_due_date, round: 1) }

  describe '#questionnaire' do
    # This method is little more than a wrapper for assignment.review_questionnaire_id()
    # Test how it responds to the combinations of various arguments it could receive

    context 'when corresponding active record for assignment_questionnaire is found' do
      before(:each) do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1, assignment_questionnaire2]
        )
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
      end

      it 'returns correct questionnaire found by used_in_round and topic_id if both used_in_round and topic_id are given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(self_review_response_map.questionnaire(1, 1)).to eq(questionnaire1)
      end

      it 'returns correct questionnaire found by used_in_round if only used_in_round is given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: nil).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(self_review_response_map.questionnaire(1, nil)).to eq(questionnaire1)
      end

      it 'returns correct questionnaire found by topic_id if only topic_id is given and there is no current round used in the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(nil)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: nil, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(self_review_response_map.questionnaire(nil, 1)).to eq(questionnaire1)
      end

      it 'returns correct questionnaire found by used_in_round and topic_id if only topic_id is given, but current round is found by the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(next_due_date)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(self_review_response_map.questionnaire(nil, 1)).to eq(questionnaire1)
      end
    end

    context 'when corresponding active record for assignment_questionnaire is not found' do
      it 'returns correct questionnaire found by type' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1, assignment_questionnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, questionnaire_id: nil).and_return([])
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(questionnaire2)
        expect(self_review_response_map.questionnaire(1, 1)).to eq(questionnaire1)
      end
    end
  end
end
