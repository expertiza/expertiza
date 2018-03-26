describe OnTheFlyCalc do
  describe "#compute total score" do
  end
  let(:Assignment1){ Assignment.new}
  let(:AssignmentQuestionaire){build(:assignment_questionnaire)}
  describe "#compute reviews hash" do
    it "Has multiple review phases with different review rubrics" do
      expect(Assignment1).to receive(:varying_rubrics_by_round?).and_return(true)
    end
    it "Does not have multiple review phases with different review rubrics" do
      expect(Assignment1).to receive(:varying_rubrics_by_round?).and_return(false)
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