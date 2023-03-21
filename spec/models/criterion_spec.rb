describe 'criterion' do
  let(:questionnaire) { Questionnaire.new min_question_score: 0, max_question_score: 5 }
  let(:criterion) { Criterion.new id: 1, type: 'Criterion', seq: 1.0, txt: 'test txt', weight: 1, questionnaire: questionnaire }
  let(:answer_no_comments) { Answer.new answer: 8 }
  let(:answer_comments) { Answer.new answer: 3, comments: 'text comments' }
  let(:question_advice) { build(:question_advice) }
  describe '#edit' do
    it 'returns the html ' do
      html = criterion.edit(0).to_s
      expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/1">Remove</a></td><td><input size="6" value="1.0" name="question[1][seq]" id="question_1_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[1][txt]" id="question_1_txt" placeholder="Edit question content here">test txt</textarea></td><td><input size="10" disabled="disabled" value="Criterion" name="question[1][type]" id="question_1_type" type="text"></td><td><input size="2" value="1" name="question[1][weight]" id="question_1_weight" type="text"></td><td>text area size <input size="3" value="" name="question[1][size]" id="question_1_size" type="text"></td><td> max_label <input size="10" value="" name="question[1][max_label]" id="question_1_max_label" type="text">  min_label <input size="12" value="" name="question[1][min_label]" id="question_1_min_label" type="text"></td></tr>')
    end
  end

  describe '#view_question_text' do
    it 'returns the html ' do
      html = criterion.view_question_text.to_s
      expect(html).to eq('<TR><TD align="left"> test txt </TD><TD align="left">Criterion</TD><td align="center">1</TD><TD align="center"> () 0 to 5 ()</TD></TR>')
    end
  end

  describe '#complete' do
    it 'returns the html without answer and no dropdown or scale' do
      html = criterion.complete(0, nil, 0, 5).to_s
      expect(html).to eq('<div><label for="responses_0">test txt</label></div>')
    end

    it 'returns the html without answer and dropdown' do
      html = criterion.complete(0, nil, 0, 5, dropdown_or_scale = 'dropdown').to_s
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div><div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" ><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\"></textarea></td>")
    end

    it 'returns the html with no comments answer and answer.answer outside questionnaire min and max and dropdown' do
      html = criterion.complete(0, answer_no_comments, 0, 5, dropdown_or_scale = 'dropdown').to_s
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div><div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" data-current-rating =8><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\"></textarea></td>")
    end

    it 'returns the html with comments answer and answer.answer between questionnaire min and max and dropdown' do
      html = criterion.complete(0, answer_comments, 0, 5, dropdown_or_scale = 'dropdown').to_s
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div><div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" data-current-rating =3><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3 selected=\"selected\">3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\">text comments</textarea></td>")
    end

    it 'returns the html without answer and scale' do
      html = criterion.complete(0, nil, 0, 5, dropdown_or_scale = 'scale').to_s
      expect(html).to eq('<div><label for="responses_0">test txt</label></div><input id="responses_0_score" name="responses[0][score]" type="hidden"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"checked="checked"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce"></textarea>')
    end

    it 'returns the html with no comments answer and answer.answer outside questionnaire min and max and scale' do
      html = criterion.complete(0, answer_no_comments, 0, 5, dropdown_or_scale = 'scale').to_s
      expect(html).to eq('<div><label for="responses_0">test txt</label></div><input id="responses_0_score" name="responses[0][score]" type="hidden"value="8"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce"></textarea>')
    end

    it 'returns the html with comments answer and answer.answer between questionnaire min and max and scale' do
      html = criterion.complete(0, answer_comments, 0, 5, dropdown_or_scale = 'scale').to_s
      expect(html).to eq('<div><label for="responses_0">test txt</label></div><input id="responses_0_score" name="responses[0][score]" type="hidden"value="3"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"checked="checked"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce">text comments</textarea>')
    end
  end

  describe '#dropdown_criterion_question' do
    it 'returns the html without answer' do
      html = criterion.dropdown_criterion_question(0, nil, 0, 5).to_s
      expect(html).to eq("<div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" ><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\"></textarea></td>")
    end

    it 'returns the html with no comments answer and answer.answer outside questionnaire min and max' do
      html = criterion.dropdown_criterion_question(0, answer_no_comments, 0, 5).to_s
      expect(html).to eq("<div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" data-current-rating =8><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\"></textarea></td>")
    end

    it 'returns the html with comments in answer and answer.answer between questionnaire min and max' do
      html = criterion.dropdown_criterion_question(0, answer_comments, 0, 5).to_s
      expect(html).to eq("<div><select id=\"responses_0_score\" name=\"responses[0][score]\" class=\"review-rating\" data-current-rating =3><option value = ''>--</option><option value=0>0</option><option value=1>1</option><option value=2>2</option><option value=3 selected=\"selected\">3</option><option value=4>4</option><option value=5>5</option></select></div><br><br><textarea id=\"responses_0_comments\" name=\"responses[0][comment]\" class=\"tinymce\">text comments</textarea></td>")
    end
  end

  describe '#scale_criterion_question' do
    it 'returns the html without answer' do
      html = criterion.scale_criterion_question(0, nil, 0, 5).to_s
      expect(html).to eq('<input id="responses_0_score" name="responses[0][score]" type="hidden"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"checked="checked"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce"></textarea>')
    end

    it 'returns the html with no comments answer and answer.answer outside questionnaire min and max' do
      html = criterion.scale_criterion_question(0, answer_no_comments, 0, 5).to_s
      expect(html).to eq('<input id="responses_0_score" name="responses[0][score]" type="hidden"value="8"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce"></textarea>')
    end

    it 'returns the html with comments answer and answer.answer between questionnaire min and max' do
      html = criterion.scale_criterion_question(0, answer_comments, 0, 5).to_s
      expect(html).to eq('<input id="responses_0_score" name="responses[0][score]" type="hidden"value="3"><table><tr><td width="10%"></td><td width="10%"><label>0</label></td><td width="10%"><label>1</label></td><td width="10%"><label>2</label></td><td width="10%"><label>3</label></td><td width="10%"><label>4</label></td><td width="10%"><label>5</label></td><td width="10%"></td></tr><tr><td width="10%"></td><td width="10%"><input type="radio" id="0" value="0" name="Radio_1"></td><td width="10%"><input type="radio" id="1" value="1" name="Radio_1"></td><td width="10%"><input type="radio" id="2" value="2" name="Radio_1"></td><td width="10%"><input type="radio" id="3" value="3" name="Radio_1"checked="checked"></td><td width="10%"><input type="radio" id="4" value="4" name="Radio_1"></td><td width="10%"><input type="radio" id="5" value="5" name="Radio_1"></td><script>jQuery("input[name=Radio_1]:radio").change(function() {var response_score = jQuery("#responses_0_score");var checked_value = jQuery("input[name=Radio_1]:checked").val();response_score.val(checked_value);});</script><td width="10%"></td><td width="10%"></td></tr></table><textarea cols=70 rows=1 id="responses_0_comments" name="responses[0][comment]" class="tinymce">text comments</textarea>')
    end
  end

  describe '#view_completed_question' do
    it 'returns the html ' do
      html = criterion.view_completed_question(0, answer_no_comments, 5).to_s
      expect(html).to eq('<b>0. test txt [Max points: 5]</b><table cellpadding="5"><tr><td><div class="c5" style="width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;">8</div></td></tr></table>')
    end
  end

  describe '#advices_criterion_question' do
    it 'returns the html' do
      html = criterion.advices_criterion_question(1, []).to_s
      expect(html).to eq('<a id="showAdvice_1" onclick="showAdvice(1)">Show advice</a><script>function showAdvice(i){var element = document.getElementById("showAdivce_" + i.toString());var show = element.innerHTML == "Hide advice";if (show){element.innerHTML="Show advice";} else{element.innerHTML="Hide advice";}toggleAdvice(i);}function toggleAdvice(i) {var elem = document.getElementById(i.toString() + "_myDiv");if (elem.style.display == "none") {elem.style.display = "";} else {elem.style.display = "none";}}</script><div id="1_myDiv" style="display: none;"></div>')
    end
  end
end
