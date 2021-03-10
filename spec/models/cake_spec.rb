describe "cake" do
    let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
    let(:cake) { Cake.new id: 1, type: "Cake", seq: 1.0, txt: "Cake type question?", weight: 1, questionnaire: questionnaire, size: 50 }
    let(:answer) { Answer.new answer: 45 }
  
    describe "#edit" do
      it "returns the html " do
        html = cake.edit(0).to_s
        expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/1">Remove</a></td><td><input size="6" value="1.0" name="question[1][seq]" id="question_1_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[1][txt]" id="question_1_txt" placeholder="Edit question content here">Cake type question?</textarea></td><td><input size="10" disabled="disabled" value="Cake" name="question[1][type]" id="question_1_type" type="text"></td><td><input size="2" value="1" name="question[1][weight]" id="question_1_weight" type="text"></td><td>text area size <input size="3" value="50" name="question[1][size]" id="question_1_size" type="text"></td></tr>')
      end
    end
  
    describe "#view_question_text" do
      it "returns the html " do
        html = cake.view_question_text.to_s
        expect(html).to eq("<TR><TD align=\"left\"> Cake type question? </TD><TD align=\"left\">Cake</TD><td align=\"center\">1</TD><TD align=\"center\">0 to 5</TD></TR>")
      end
    end
    
    describe "#view_completed_question" do
      it "returns the html " do
        html = cake.view_completed_question(0, answer).to_s
        expect(html).to eq("<b>0. Cake type question?</b><div class=\"c5\" style=\"width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;\">45</div><b>Comments:</b>")
      end
    end
  end 