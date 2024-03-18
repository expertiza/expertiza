describe 'scale' do
  let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
  let(:scale) { Scale.new id: 1, type: 'Scale', seq: 1.0, txt: 'test txt', weight: 1, questionnaire: questionnaire }
  let(:answer) { Answer.new answer: 8 }

  describe '#edit' do
    it 'returns the html ' do
      html = scale.edit(0).to_s
      expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/1">Remove</a></td><td><input size="6" value="1.0" name="question[1][seq]" id="question_1_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[1][txt]" id="question_1_txt" placeholder="Edit question content here">test txt</textarea></td><td><input size="10" disabled="disabled" value="Scale" name="question[1][type]" id="question_1_type" type="text"></td><td><input size="2" value="1" name="question[1][weight]" id="question_1_weight" type="text"></td><td> max_label <input size="10" value="" name="question[1][max_label]" id="question_1_max_label" type="text">  min_label <input size="12" value="" name="question[1][min_label]" id="question_1_min_label" type="text"></td></tr>')
    end
  end

  describe '#view_question_text' do
    it 'returns the html ' do
      html = scale.view_question_text.to_s
      expect(html).to eq('<TR><TD align="left"> test txt </TD><TD align="left">Scale</TD><td align="center">1</TD><TD align="center"> () 0 to 5 ()</TD></TR>')
    end
  end

  describe '#complete' do
    it 'returns the html ' do
      html = scale.complete(0, 0, 5, nil).to_s
      expect(html).to eq('<div><label for="responses_0">test txt</label></div><input id="responses_0_score" name="responses[0][score]" type="hidden"><input id="responses_0_comments" name="responses[0][comment]" type="hidden" value=""><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"checked="checked"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><br/>')
    end
  end
  describe '#view_completed_question' do
    it 'returns the html ' do
      html = scale.view_completed_question(0, answer, 5).to_s
      expect(html).to eq('<b>0. test txt</b><BR/><BR/><B>Score:</B> <FONT style="BACKGROUND-COLOR:gold">8</FONT> out of <B>5</B></TD>')
    end
  end
end
