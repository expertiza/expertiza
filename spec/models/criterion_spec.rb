require 'rails_helper'

describe "criterion" do
  let(:questionnaire){Questionnaire.new min_question_score: 0, max_question_score: 5}
  let(:criterion){Criterion.new id:1, type: "Scale", seq:1.0, txt:"test txt", weight: 1,questionnaire: questionnaire}
  let(:answer){Answer.new answer:8}

  describe "#edit" do
    it "returns the html " do
      html = criterion.edit(0).to_s
      expect(html).to eq("<tr><td align=\"center\"><a rel=\"nofollow\" data-method=\"delete\" href=\"/questions/1\">Remove</a></td><td><input size=\"6\" value=\"1.0\" name=\"question[1][seq]\" id=\"question_1_seq\" type=\"text\"></td><td><textarea cols=\"50\" rows=\"1\" name=\"question[1][txt]\" id=\"question_1_txt\">test txt</textarea></td><td><input size=\"10\" disabled=\"disabled\" value=\"Scale\" name=\"question[1][type]\" id=\"question_1_type\" type=\"text\"></td><td><input size=\"2\" value=\"1\" name=\"question[1][weight]\" id=\"question_1_weight\" type=\"text\"></td><td>text area size <input size=\"3\" value=\"\" name=\"question[1][size]\" id=\"question_1_size\" type=\"text\"></td><td> max_label <input size=\"10\" value=\"\" name=\"question[1][max_label]\" id=\"question_1_max_label\" type=\"text\">  min_label <input size=\"10\" value=\"\" name=\"question[1][min_label]\" id=\"question_1_min_label\" type=\"text\"></td></tr>")
    end
  end

  describe "#view_question_text" do
    it "returns the html " do
      html = criterion.view_question_text.to_s
      expect(html).to eq("<TR><TD align=\"left\"> test txt </TD><TD align=\"left\">Scale</TD><td align=\"center\">1</TD><TD align=\"center\"> () 0 to 5 ()</TD></TR>")
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
      expect(html).to eq( "<big><b>Question 0:</b> <I>test txt</I></big><BR/><BR/><TABLE CELLPADDING=\"5\"><TR><TD valign=\"top\"><B>Score: </B></TD><TD><FONT style=\"BACKGROUND-COLOR:gold\">8</FONT> out of <B>5</B></TD></TR></TD></TR></TABLE><BR/>")
    end
  end

end