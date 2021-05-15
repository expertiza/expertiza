describe MultipleChoiceCheckbox do
  let(:multiple_choice_checkbox) { build(:multiple_choice_checkbox, id: 1)}
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  describe '#edit' do
    it 'returns the html' do
      qc = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return([qc, qc, qc, qc])
      allow(qc).to receive(:iscorrect).and_return(true)
      allow(qc).to receive(:txt).and_return('question text')
      expect(multiple_choice_checkbox.edit).to eq('<tr><td><textarea cols="100" name="question[1][txt]" id="question_1_txt">Test question:</textarea></td></tr><tr><td>Question Weight: <input type="number" name="question_weights[1][txt]" id="question_wt_1_txt" value="1" min="0" /></td></tr><tr><td><input type="hidden" name="quiz_question_choices[1][MultipleChoiceCheckbox][1][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_1_iscorrect" value="0" /><input type="checkbox" name="quiz_question_choices[1][MultipleChoiceCheckbox][1][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_1_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_question_choices[1][MultipleChoiceCheckbox][1][txt]" id="quiz_question_choices_1_MultipleChoiceCheckbox_1_txt" value="question text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_question_choices[1][MultipleChoiceCheckbox][2][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_2_iscorrect" value="0" /><input type="checkbox" name="quiz_question_choices[1][MultipleChoiceCheckbox][2][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_2_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_question_choices[1][MultipleChoiceCheckbox][2][txt]" id="quiz_question_choices_1_MultipleChoiceCheckbox_2_txt" value="question text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_question_choices[1][MultipleChoiceCheckbox][3][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_3_iscorrect" value="0" /><input type="checkbox" name="quiz_question_choices[1][MultipleChoiceCheckbox][3][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_3_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_question_choices[1][MultipleChoiceCheckbox][3][txt]" id="quiz_question_choices_1_MultipleChoiceCheckbox_3_txt" value="question text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_question_choices[1][MultipleChoiceCheckbox][4][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_4_iscorrect" value="0" /><input type="checkbox" name="quiz_question_choices[1][MultipleChoiceCheckbox][4][iscorrect]" id="quiz_question_choices_1_MultipleChoiceCheckbox_4_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_question_choices[1][MultipleChoiceCheckbox][4][txt]" id="quiz_question_choices_1_MultipleChoiceCheckbox_4_txt" value="question text" size="40" /></td></tr>')
    end
  end
  describe '#valid?' do
    context 'when the question itself does not have txt' do
      it 'returns "Please make sure all questions have text"' do
        allow(multiple_choice_checkbox).to receive(:txt).and_return(nil)
        qc = double('QuizQuestionChoice')
        questions = {"1" => qc, "2" => qc, "3" => qc, "4" => qc}
        expect(multiple_choice_checkbox.valid?(questions)).to eq("Please make sure all questions have text")
      end
    end
    context 'when a choice does not have txt' do
      it 'returns "Please make sure every question has text for all options"' do
        qc = double('QuizQuestionChoice')
        allow(qc).to receive(:txt).and_return(nil)
        questions = {"1" => qc, "2" => qc, "3" => qc, "4" => qc}
        expect(multiple_choice_checkbox.valid?(questions)).to eq("Please make sure every question has text for all options")
      end
    end
    context 'when no choices are correct' do
      it 'returns "Please select a correct answer for all questions"' do
        qc = double('QuizQuestionChoice')
        allow(qc).to receive(:iscorrect).and_return('0')
        allow(qc).to receive(:txt).and_return('question text')
        questions = {"1" => qc, "2" => qc, "3" => qc, "4" => qc}
        expect(multiple_choice_checkbox.valid?(questions)).to eq("Please select a correct answer for all questions")
      end
    end
    context 'when only 1 choices are correct' do
      it 'returns "A multiple-choice checkbox question should have more than one correct answer."' do
        qc = double('QuizQuestionChoice')
        allow(qc).to receive(:iscorrect).and_return('0')
        allow(qc).to receive(:txt).and_return('question text')
        qc_true = double('QuizQuestionChoice')
        allow(qc_true).to receive(:iscorrect).and_return('1')
        allow(qc_true).to receive(:txt).and_return('question text')
        questions = {"1" => qc_true, "2" => qc, "3" => qc, "4" => qc}
        expect(multiple_choice_checkbox.valid?(questions)).to eq("A multiple-choice checkbox question should have more than one correct answer.")
      end
    end
    context 'when 2 choices are correct' do
      it 'returns "valid"' do
        qc = double('QuizQuestionChoice')
        allow(qc).to receive(:iscorrect).and_return('1')
        allow(qc).to receive(:txt).and_return('question text')
        qc_true = double('QuizQuestionChoice')
        allow(qc_true).to receive(:iscorrect).and_return('1')
        allow(qc_true).to receive(:txt).and_return('question text')
        questions = {"1" => qc_true, "2" => qc, "3" => qc, "4" => qc}
        expect(multiple_choice_checkbox.valid?(questions)).to eq("valid")
      end
    end
  end
  describe '#get_formatted_question_type' do
    it 'returns "Multiple Choice - Checked"' do
      expect(multiple_choice_checkbox.get_formatted_question_type).to eq('Multiple Choice - Checked')
    end
  end
  describe '#compute_question_score' do
    it 'returns 0' do
      expect(Question.compute_question_score).to eq(0)
    end
  end
  describe '#export_fields' do
    it 'returns the column headers' do
      expect(Question.export_fields([])).to eq(["Seq", "Question", "Type", "Weight", "text area size", "max_label", "min_label"])
    end
  end

  describe '#get_all_questions_with_comments_available' do
    context 'when the assignment has no questionnaires associated' do
      it 'returns an empty array' do 
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:questionnaires).and_return([])
        expect(Question.get_all_questions_with_comments_available(assignment.id)).to eq([]) 
      end
    end
  end
end