describe "criterion" do
  let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
  let(:criterion) { Criterion.new id: 1, type: "Criterion", seq: 1.0, txt: "test txt", weight: 1, questionnaire: questionnaire }
  let(:answer) { Answer.new answer: 8 }

  describe "#complete" do
    it "returns the html " do
      html = criterion.complete(0, nil, 0, 5).to_s
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div>")
    end
  end
  #
  describe "#view_completed_question" do
    it "returns the html " do
      html = criterion.view_completed_question(0, answer, 5).to_s
      expect(html).to eq("<b>0. test txt [Max points: 5]</b><table cellpadding=\"5\"><tr><td><div class=\"c5\" style=\"width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;\">8</div></td></tr></table>")
    end
  end
end
