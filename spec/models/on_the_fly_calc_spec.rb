describe OnTheFlyCalc do
  let(:questionnaire) {build(:questionnaire)}
  let(:question1){ build(:question, questionnaire: questionnaire) }
  let(:Assignment){ Assignment.new}
  describe "#compute total score" do
  end
  describe "#compute reviews hash" do

    context "Has multiple review phases with different review rubrics" do
      it "calls scores_varying_rubrics" do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(true)
        Assignment.compute_reviews_hash
        expect(Assignment).to receive(:scores_varying_rubrics)
      end
    end
    context "Does not have multiple review phases with different review rubrics" do
      it "calls scores_non_varying_rubrics" do
        allow(Assignment).to receive(:varying_rubrics_by_round?).and_return(false)
        Assignment.compute_reviews_hash
        expect(Assignment).to receive(:scores_non_varying_rubrics)
      end
    end

  end
  describe "#compute avg and ranges hash" do

    context "Has multiple review phases with different review rubrics" do
    end

    context "Does not have multiple review phases with different review rubrics" do
    end

  end
  descirbe"#scores" do

    context "Has multiple review phases with different review rubrics" do
    end

    context "Does not have multiple review phases with different review rubrics" do
    end

  end

end