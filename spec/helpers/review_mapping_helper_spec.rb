describe "ReviewMappingHelper" do
  describe "#review_score_helper_for_team" do
    before(:each) do
      @review_answers = [{'reviewer_id': '2', 'answer': 54}, {'reviewer_id': '1', 'answer': 24}, {'reviewer_id': '2', 'answer': 25}]
    end

    it "The review_score_helper_for_team method calculates the total review scores for each review" do
      question_answers = helper.review_score_helper_for_team(@review_answers)
      expect(question_answers).to include('1' => 24,'2' => 79)
    end
  end

  describe "#get_score_metrics" do
    before(:each) do
      @review_scores = {'1' => 50, '2' => 40, '3' => 60}
    end

    it "The get_score_metrics method calculates various metrics used in the conflict report" do
      metric = helper.get_score_metrics(@review_scores, 50)
      expect(metric[:average]).to eq 50.0
      expect(metric[:std]).to eq 8.16
      expect(metric[:upper_tolerance_limit]).to eq 50
      expect(metric[:lower_tolerance_limit]).to eq 33.68
    end
  end
end