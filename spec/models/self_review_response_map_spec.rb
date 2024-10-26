describe SelfReviewResponseMap do
  let(:assignment) { build(:assignment, id: 1) }
  let(:assignment_itemnaire1) { build(:assignment_itemnaire, id: 1, assignment_id: 1, itemnaire_id: 1) }
  let(:assignment_itemnaire2) { build(:assignment_itemnaire, id: 2, assignment_id: 1, itemnaire_id: 2) }
  let(:itemnaire1) { build(:itemnaire, type: 'ReviewQuestionnaire') }
  let(:itemnaire2) { build(:itemnaire, type: 'MetareviewQuestionnaire') }
  let(:self_review_response_map) { build(:self_review_response_map, assignment: assignment) }
  let(:next_due_date) { build(:assignment_due_date, round: 1) }

  describe '#itemnaire' do
    # This method is little more than a wrapper for assignment.review_itemnaire_id()
    # Test how it responds to the combinations of various arguments it could receive

    context 'when corresponding active record for assignment_itemnaire is found' do
      before(:each) do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_itemnaire1, assignment_itemnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
      end

      it 'returns correct itemnaire found by used_in_round and topic_id if both used_in_round and topic_id are given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_itemnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(itemnaire1)
        expect(self_review_response_map.itemnaire(1, 1)).to eq(itemnaire1)
      end

      it 'returns correct itemnaire found by used_in_round if only used_in_round is given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: nil).and_return(
          [assignment_itemnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(itemnaire1)
        expect(self_review_response_map.itemnaire(1, nil)).to eq(itemnaire1)
      end

      it 'returns correct itemnaire found by topic_id if only topic_id is given and there is no current round used in the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(nil)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: nil, topic_id: 1).and_return(
          [assignment_itemnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(itemnaire1)
        expect(self_review_response_map.itemnaire(nil, 1)).to eq(itemnaire1)
      end

      it 'returns correct itemnaire found by used_in_round and topic_id if only topic_id is given, but current round is found by the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(next_due_date)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_itemnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(itemnaire1)
        expect(self_review_response_map.itemnaire(nil, 1)).to eq(itemnaire1)
      end
    end

    context 'when corresponding active record for assignment_itemnaire is not found' do
      it 'returns correct itemnaire found by type' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_itemnaire1, assignment_itemnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(itemnaire2)
        expect(self_review_response_map.itemnaire(1, 1)).to eq(itemnaire1)
      end
    end
  end
end
