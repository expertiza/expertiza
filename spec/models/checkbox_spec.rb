describe Checkbox do
  let!(:checkbox) { Checkbox.new id: 10, type: 'Checkbox', seq: 1.0, txt: 'test txt', weight: 11 }
  let!(:answer) { Answer.new answer: 1 }
  let!(:checkbox1) { Checkbox.create(id: 1, type: 'Checkbox', seq: 2.0, txt: 'test txt2', weight: 11) }
  let!(:checkbox2) { Checkbox.create(id: 2, type: 'Checkbox', seq: 3.0, txt: 'test txt3', weight: 12) }
  let!(:checkbox3) { Checkbox.create(id: 3, type: 'Checkbox', seq: 4.0, txt: 'test txt4', weight: 13) }

  describe '#edit' do
    it 'returns the html ' do
      html = checkbox.edit(0).to_s
      expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/10">Remove</a></td><td><input size="6" value="1.0" name="question[10][seq]" id="question_10_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[10][txt]" id="question_10_txt" placeholder="Edit question content here">test txt</textarea></td><td><input size="10" disabled="disabled" value="Checkbox" name="question[10][type]" id="question_10_type" type="text"></td><td><!--placeholder (UnscoredQuestion does not need weight)--></td></tr>')
    end
  end

  describe '#complete' do
    it 'returns the html' do
      html = checkbox2.complete(1, answer)
      expect(html).to eq('<input id="responses_1_comments" name="responses[1][comment]" type="hidden" value=""><input id="responses_1_score" name="responses[1][score]" type="hidden"value="1"><input id="responses_1_checkbox" type="checkbox" onchange="checkbox1Changed()"checked="checked"><label for="responses_1">&nbsp;&nbsp;test txt3</label><script>function checkbox1Changed() { var checkbox = jQuery("#responses_1_checkbox"); var response_score = jQuery("#responses_1_score");if (checkbox.is(":checked")) {response_score.val("1");} else {response_score.val("0");}}</script><BR/>')
    end
  end

  describe '#view_question_text' do
    it 'returns the html ' do
      html = checkbox2.view_question_text.to_s
      expect(html).to eq('<TR><TD align="left"> test txt3 </TD><TD align="left">Checkbox</TD><td align="center">12</TD><TD align="center">Checked/Unchecked</TD></TR>')
    end
  end

  describe '#view_completed_question' do
    it 'returns the html ' do
      html = checkbox2.view_completed_question(0, answer).to_s
      expect(html).to eq('<b>0. &nbsp;&nbsp;<img src="/assets/Check-icon.png">test txt3</b>')
    end
  end
end
