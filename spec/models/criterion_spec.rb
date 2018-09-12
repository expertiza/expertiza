describe Criterion do
  let(:questionnaire) { Questionnaire.new min_question_score: 2, max_question_score: 8 }
  let(:criterion) { Criterion.new id: 1, type: 'Criterion', seq: 1.0, txt: 'test txt', weight: 1, questionnaire: questionnaire }
  let(:criterion_labels) { Criterion.new id: 2, type: 'Criterion', seq: 1.0, txt: 'test txt', weight: 1, questionnaire: questionnaire, min_label: 'Min', max_label: 'Max' }
  let(:answer) { Answer.new id: 1, answer: 4 }
  let(:answer_comments) { Answer.new id: 2, answer: 4, comments: 'test comment', question: question, question_id: 1 }
  let(:question) { Question.new id: 1, type: 'Criterion' }

  describe '#edit' do
    it 'returns the correct html string' do
      html = criterion.edit
      expect(html).to eq("<tr><td align=\"center\"><a rel=\"nofollow\" data-method=\"delete\" href=\"/questions/1\">Remove</a></td><td><input type=\"text\" name=\"question[1][seq]\" id=\"question_1_seq\" value=\"1.0\" size=\"6\" /></td><td><textarea name=\"question[1][txt]\" id=\"question_1_txt\" cols=\"50\" rows=\"1\" placeholder=\"Edit question content here\">\ntest txt</textarea></td><td><input type=\"text\" name=\"question[1][type]\" id=\"question_1_type\" value=\"Criterion\" size=\"10\" disabled=\"disabled\" /></td><td><input type=\"text\" name=\"question[1][weight]\" id=\"question_1_weight\" value=\"1\" size=\"2\" /></td><td>text area size <input type=\"text\" name=\"question[1][size]\" id=\"question_1_size\" value=\"\" size=\"3\" /></td><td> max_label <input type=\"text\" name=\"question[1][max_label]\" id=\"question_1_max_label\" value=\"\" size=\"10\" /> min_label <input type=\"text\" name=\"question[1][min_label]\" id=\"question_1_min_label\" value=\"\" size=\"12\" /></td></tr>")
    end
  end

  describe '#view_question_text' do
    it 'returns html string with no labels when labels are undefined' do
      html = criterion.view_question_text
      expect(html).to eq("<tr><td align=\"left\">test txt</td><td align=\"left\">Criterion</td><td align=\"center\">1</td><td align=\"center\">2 to 8</td></tr>")
    end

    it 'html string includes labels when labels are defined' do
      html = criterion_labels.view_question_text
      expect(html).to include("(Min) 2 to 8 (Max)")
    end
  end

  describe '#complete' do
    let(:question_advice) { QuestionAdvice.new id: 1, advice: 'advice' }

    it 'returns the correct html string given the dropdown option' do
      html = criterion_labels.complete(0, 1, 4, 'dropdown', answer_comments)
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div><div><select name=\"responses[0][score]\" id=\"responses_0_score\" class=\"review-rating\"><option value=\"\">--</option>\n<option value=\"1\">1-Min</option>\n<option value=\"2\">2</option>\n<option value=\"3\">3</option>\n<option selected=\"selected\" value=\"4\">4-Max</option></select></div><br /><br /><textarea name=\"responses[0][comment]\" id=\"responses_0_comment\" class=\"tinymce\">\ntest comment</textarea>")
    end

    it 'returns the correct html string given the scale option' do
      html = criterion_labels.complete(0, 1, 4, 'scale', answer_comments)
      expect(html).to eq("<div><label for=\"responses_0\">test txt</label></div><input type=\"hidden\" name=\"responses[0][score]\" id=\"responses_0_score\" value=\"4\" /><table><tr><td width=\"10%\"></td><td width=\"10%\"><label>1</label></td><td width=\"10%\"><label>2</label></td><td width=\"10%\"><label>3</label></td><td width=\"10%\"><label>4</label></td><td width=\"10%\"></td></tr><tr><td width=\"10%\">Min</td><td width=\"10%\"><input type=\"radio\" name=\"Radio_2\" id=\"1\" value=\"1\" /></td><td width=\"10%\"><input type=\"radio\" name=\"Radio_2\" id=\"2\" value=\"2\" /></td><td width=\"10%\"><input type=\"radio\" name=\"Radio_2\" id=\"3\" value=\"3\" /></td><td width=\"10%\"><input type=\"radio\" name=\"Radio_2\" id=\"4\" value=\"4\" checked=\"checked\" /></td><script>\n//<![CDATA[\njQuery(\"input[name=Radio_2]:radio\").change(function() {var response_score = jQuery(\"#responses_0_score\");var checked_value = jQuery(\"input[name=Radio_2]:checked\").val();response_score.val(checked_value);});\n//]]>\n</script><td width=\"10%\">Max</td><td width=\"10%\"></td></tr></table><textarea name=\"responses[0][comment]\" id=\"responses_0_comment\" class=\"tinymce\" cols=\"70\" rows=\"1\">\ntest comment</textarea>")
    end

    it 'returns html string with advice for each question' do
      allow(QuestionAdvice).to receive(:where).with(question_id: 2).and_return([question_advice])
      html = criterion_labels.complete(0, 1, 4, 'dropdown', answer_comments)
      expect(html).to include("<a id=\"showAdivce_2\" onclick=\"showAdvice(2)\" href=\"#\">Show advice</a><script>\n//<![CDATA[\nfunction showAdvice(i){var element = document.getElementById(\"showAdivce_\" + i.toString());var show = element.innerHTML == \"Hide advice\";if (show){element.innerHTML=\"Show advice\";}else{element.innerHTML=\"Hide advice\";}toggleAdvice(i);}function toggleAdvice(i) {var elem = document.getElementById(i.toString() + \"_myDiv\");if (elem.style.display == \"none\") {elem.style.display = \"\";} else {elem.style.display = \"none\";}}\n//]]>\n</script><div id=\"2_myDiv\" style=\"display: none;\"><a id=\"changeScore_2\" onclick=\"changeScore(0,0)\" href=\"#\">8 - advice</a><br /><script>\n//<![CDATA[\nfunction changeScore(i, j) {var elem = jQuery(\"#responses_\" + i.toString() + \"_score\");var opts = elem.children(\"option\").length;elem.val((8 - j).toString());}\n//]]>\n</script></div>")
    end
  end

  describe '#view_completed_question' do
    let(:tag_prompt) { TagPrompt.new id: 1, prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox' }
    let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt_id: 1,  question_type: 'Criterion', answer_length_threshold: 5 }

    it 'returns html string with no comments when comments are undefined' do
      html = criterion.view_completed_question(1, answer, 5)
      expect(html).to eq("<b>1. test txt [Max points: 5]</b><table cellpadding=\"5\"><tr><td><div class=\"c4\" style=\"width:30px; height:30px; border-radius:50%; font-size:15px; color:black; line-height:30px; text-align:center;\">4</div></td></tr></table>")
    end

    it 'returns html string with comments when comments are defined' do
      html = criterion.view_completed_question(1, answer_comments, 5)
      expect(html).to include("<td style=\"padding-left:10px\"><br />test comment</td>")
    end

    it 'returns html string with tag prompts when method is called with tag prompt deployments' do
      allow(Question).to receive(:find).with(1).and_return(question)
      allow(TagPrompt).to receive(:find).with(1).and_return(tag_prompt)
      html = criterion.view_completed_question(1, answer_comments, 5, [tag_dep], 1)
      expect(html).to include("<tr><td colspan=\"2\"><div class=\"toggle-container tag_prompt_container\" title=\"test desc\"><input type=\"checkbox\" name=\"tag_checkboxes[]\" id=\"tag_prompt_2_1\" value=\"0\" onLoad=\"toggleLabel(this)\" onChange=\"toggleLabel(this); save_tag(2, 1, tag_prompt_2_1);\" /><label for=\"tag_prompt_2_1\">test prompt</label></div></td></tr>")
    end
  end
end
