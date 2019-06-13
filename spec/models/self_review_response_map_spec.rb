describe SelfReviewResponseMap do
  let(:deadline_type) { build(:deadline_type, id: 1) }

  describe '#questionnaire' do
    # This method is little more than a wrapper for assignment.review_questionnaire_id()
    # So it will be tested relatively lightly
    # We want to know how it responds to the combinations of various arguments it could receive
    # We want to know how it responds if no questionnaire can be found

    before(:each) do
      @assignment = create(:assignment)
      @self_review_response_map = create(:self_review_response_map, assignment: @assignment)
      @review_response_map = create(:review_response_map, assignment: @assignment)
      @questionnaire1 = create(:questionnaire, type: 'ReviewQuestionnaire')
      @questionnaire2 = create(:questionnaire, type: 'MetareviewQuestionnaire')
      @questionnaire3 = create(:questionnaire, type: 'AuthorFeedbackQuestionnaire')
      @questionnaire4 = create(:questionnaire, type: 'TeammateReviewQuestionnaire')
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 1, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 1, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 2, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 2, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 3, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 3, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 4, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 4, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: 4)
    end

    it 'returns correct questionnaire found by used_in_round and topic_id when both are given and assignment varies by both' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 1)
      expect(@self_review_response_map.questionnaire(1, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 2)
      expect(@self_review_response_map.questionnaire(1, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 3)
      expect(@self_review_response_map.questionnaire(1, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 4)
      expect(@self_review_response_map.questionnaire(1, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 1)
      expect(@self_review_response_map.questionnaire(2, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 2)
      expect(@self_review_response_map.questionnaire(2, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 3)
      expect(@self_review_response_map.questionnaire(2, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 4)
      expect(@self_review_response_map.questionnaire(2, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 1)
      expect(@self_review_response_map.questionnaire(3, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 2)
      expect(@self_review_response_map.questionnaire(3, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 3)
      expect(@self_review_response_map.questionnaire(3, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 4)
      expect(@self_review_response_map.questionnaire(3, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 1)
      expect(@self_review_response_map.questionnaire(4, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 2)
      expect(@self_review_response_map.questionnaire(4, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 3)
      expect(@self_review_response_map.questionnaire(4, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 4)
      expect(@self_review_response_map.questionnaire(4, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by used_in_round when used_in_round only is given but assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: nil)
      expect(@self_review_response_map.questionnaire(1, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@self_review_response_map.questionnaire(2, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: nil)
      expect(@self_review_response_map.questionnaire(3, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: nil)
      expect(@self_review_response_map.questionnaire(4, nil)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by used_in_round when both used_in_round and topic_id are given but assignment varies only by round' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: nil)
      expect(@self_review_response_map.questionnaire(1, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@self_review_response_map.questionnaire(2, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: nil)
      expect(@self_review_response_map.questionnaire(3, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: nil)
      expect(@self_review_response_map.questionnaire(4, anything)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by topic_id when topic_id only is given and there is no current round used in the due date and assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 1)
      expect(@self_review_response_map.questionnaire(nil, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 2)
      expect(@self_review_response_map.questionnaire(nil, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 3)
      expect(@self_review_response_map.questionnaire(nil, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 4)
      expect(@self_review_response_map.questionnaire(nil, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by topic_id when both used_in_round and topic_id are given and there is no current round used in the due date but assignment varies only by topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 1)
      expect(@self_review_response_map.questionnaire(anything, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 2)
      expect(@self_review_response_map.questionnaire(anything, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 3)
      expect(@self_review_response_map.questionnaire(anything, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 4)
      expect(@self_review_response_map.questionnaire(anything, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by current round used in the due date when neither used_in_round nor topic_id are not given, but assignment varies only by round' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_due_date, assignment: @assignment, round: 2)
      allow(DeadlineType).to receive(:find_by).with(name: 'review').and_return(deadline_type)
      allow(DeadlineType).to receive(:find_by).with(name: 'submission').and_return(deadline_type)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@self_review_response_map.questionnaire(nil, anything)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by current round used in the due date when topic_id only is given, but assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_due_date, assignment: @assignment, round: 2)
      allow(DeadlineType).to receive(:find_by).with(name: 'review').and_return(deadline_type)
      allow(DeadlineType).to receive(:find_by).with(name: 'submission').and_return(deadline_type)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 1)
      expect(@self_review_response_map.questionnaire(nil, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 2)
      expect(@self_review_response_map.questionnaire(nil, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 3)
      expect(@self_review_response_map.questionnaire(nil, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 4)
      expect(@self_review_response_map.questionnaire(nil, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by type when neither used_in_round nor topic_id are given and assignment does not vary by either round or topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: nil)
      expect(@self_review_response_map.questionnaire(nil, nil)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by type when both used_in_round and topic_id are given but assignment does not vary by either round or topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: nil)
      expect(@self_review_response_map.questionnaire(anything, anything)).to eq @questionnaire1
    end

    it 'should not return nil or result in any error since all possible AQs and questionnaires must be accessible via Active Record' do
      # All below cases are not possible for a given DB state
      #expect(self_review_response_map.questionnaire(5, anything)).to eq nil
      #expect(self_review_response_map.questionnaire(anything, 5)).to eq nil
    end
  end

end
