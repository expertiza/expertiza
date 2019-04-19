describe SelfReviewResponseMap do

  describe '#questionnaire' do

    # This method is little more than a wrapper for assignment.review_questionnaire_id()
    # So it will be tested relatively lightly
    # We want to know how it responds to the combinations of various arguments it could receive

    it "returns the correct questionnaire when round not given" do
      # create multiple questionnaires and assignment_questionnaires,
      # for confidence that correct questionnaire is returned
      assignment = create(:assignment)
      self_review_response_map = create(:self_review_response_map, assignment: assignment)
      questionnaire_1 = create(:questionnaire)
      questionnaire_2 = create(:questionnaire)
      create(:assignment_questionnaire, assignment: assignment, questionnaire: questionnaire_1, used_in_round: 1)
      create(:assignment_questionnaire, assignment: assignment, questionnaire: questionnaire_2, used_in_round: 2)
      expect(self_review_response_map.questionnaire(nil).id).to eql questionnaire_1.id
    end

    it "returns the correct questionnaire when round given" do
      # create multiple questionnaires and assignment_questionnaires,
      # for confidence that correct questionnaire is returned
      assignment = create(:assignment)
      self_review_response_map = create(:self_review_response_map, assignment: assignment)
      questionnaire_1 = create(:questionnaire)
      questionnaire_2 = create(:questionnaire)
      create(:assignment_questionnaire, assignment: assignment, questionnaire: questionnaire_1, used_in_round: 1)
      create(:assignment_questionnaire, assignment: assignment, questionnaire: questionnaire_2, used_in_round: 2)
      expect(self_review_response_map.questionnaire(2).id).to eql questionnaire_2.id
    end

  end

end
