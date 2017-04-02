require 'rails_helper'

describe "criterion" do
  let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
  let(:criterion) { Criterion.new id: 1, type: "Criterion", seq: 1.0, txt: "test txt", weight: 1, questionnaire: questionnaire }
  let(:answer) { Answer.new answer: 8 }

  describe "#edit" do
    it "returns the html " do
      html = criterion.edit(0).to_s
      expect(html).to eq("<tr><td align=\"center\"><a rel=\"nofollow\" data-method=\"delete\" href=\"/questions/1\">Remove</a></td><td><input size=\"6\" value=\"1.0\" name=\"question[1][seq]\" id=\"question_1_seq\" type=\"text\"></td><td><textarea cols=\"50\" rows=\"1\" name=\"question[1][txt]\" id=\"question_1_txt\" placeholder=\"Edit question content here\">test txt</textarea></td><td><input size=\"10\" disabled=\"disabled\" value=\"Criterion\" name=\"question[1][type]\" id=\"question_1_type\" type=\"text\"></td><td><input size=\"2\" value=\"1\" name=\"question[1][weight]\" id=\"question_1_weight\" type=\"text\"></td><td>text area size <input size=\"3\" value=\"\" name=\"question[1][size]\" id=\"question_1_size\" type=\"text\"></td><td> max_label <input size=\"10\" value=\"\" name=\"question[1][max_label]\" id=\"question_1_max_label\" type=\"text\">  min_label <input size=\"12\" value=\"\" name=\"question[1][min_label]\" id=\"question_1_min_label\" type=\"text\"></td></tr>")
    end
  end

  describe "#view_question_text" do
    it "returns the html " do
      html = criterion.view_question_text.to_s
      expect(html).to eq("<TR><TD align=\"left\"> test txt </TD><TD align=\"left\">Criterion</TD><td align=\"center\">1</TD><TD align=\"center\"> () 0 to 5 ()</TD></TR>")
    end
  end

  describe "#complete" do
    it "returns the html " do
      html = criterion.complete(0, nil, 0, 5).to_s
      expect(html).to eq("<li><div><label for=\"responses_0\">test txt</label></div>")
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
