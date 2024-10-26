describe MultipleChoiceCheckbox do
  let(:multiple_choice_checkbox) { build(:multiple_choice_checkbox, id: 1) }
  let(:itemnaire1) { build(:itemnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:itemnaire2) { build(:itemnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:scored_item) { build(:scored_item, id: 1) }
  let(:item) { build(:item) }
  describe '#edit' do
    it 'returns the html' do
      qc = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).with(item_id: 1).and_return([qc, qc, qc, qc])
      allow(qc).to receive(:iscorrect).and_return(true)
      allow(qc).to receive(:txt).and_return('item text')
      expect(multiple_choice_checkbox.edit).to eq('<tr><td><textarea cols="100" name="item[1][txt]" id="item_1_txt">Test item:</textarea></td></tr><tr><td>Question Weight: <input type="number" name="item_weights[1][txt]" id="item_wt_1_txt" value="1" min="0" /></td></tr><tr><td><input type="hidden" name="quiz_item_choices[1][MultipleChoiceCheckbox][1][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_1_iscorrect" value="0" /><input type="checkbox" name="quiz_item_choices[1][MultipleChoiceCheckbox][1][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_1_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_item_choices[1][MultipleChoiceCheckbox][1][txt]" id="quiz_item_choices_1_MultipleChoiceCheckbox_1_txt" value="item text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_item_choices[1][MultipleChoiceCheckbox][2][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_2_iscorrect" value="0" /><input type="checkbox" name="quiz_item_choices[1][MultipleChoiceCheckbox][2][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_2_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_item_choices[1][MultipleChoiceCheckbox][2][txt]" id="quiz_item_choices_1_MultipleChoiceCheckbox_2_txt" value="item text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_item_choices[1][MultipleChoiceCheckbox][3][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_3_iscorrect" value="0" /><input type="checkbox" name="quiz_item_choices[1][MultipleChoiceCheckbox][3][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_3_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_item_choices[1][MultipleChoiceCheckbox][3][txt]" id="quiz_item_choices_1_MultipleChoiceCheckbox_3_txt" value="item text" size="40" /></td></tr><tr><td><input type="hidden" name="quiz_item_choices[1][MultipleChoiceCheckbox][4][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_4_iscorrect" value="0" /><input type="checkbox" name="quiz_item_choices[1][MultipleChoiceCheckbox][4][iscorrect]" id="quiz_item_choices_1_MultipleChoiceCheckbox_4_iscorrect" value="1" checked="checked" /><input type="text" name="quiz_item_choices[1][MultipleChoiceCheckbox][4][txt]" id="quiz_item_choices_1_MultipleChoiceCheckbox_4_txt" value="item text" size="40" /></td></tr>')
    end
  end
  describe '#isvalid' do
    context 'when the item itself does not have txt' do
      it 'returns "Please make sure all items have text"' do
        allow(multiple_choice_checkbox).to receive(:txt).and_return('')
        items = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '1' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expect(multiple_choice_checkbox.isvalid(items)).to eq('Please make sure all items have text')
      end
    end
    context 'when a choice does not have txt' do
      it 'returns "Please make sure every item has text for all options"' do
        items = { '1' => { txt: '', iscorrect: '1' }, '2' => { txt: '', iscorrect: '1' }, '3' => { txt: '', iscorrect: '0' }, '4' => { txt: '', iscorrect: '0' } }
        expect(multiple_choice_checkbox.isvalid(items)).to eq('Please select a correct answer for all items')
      end
    end
    context 'when no choices are correct' do
      it 'returns "Please select a correct answer for all items"' do
        items = { '1' => { txt: 'item text', iscorrect: '0' }, '2' => { txt: 'item text', iscorrect: '0' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expect(multiple_choice_checkbox.isvalid(items)).to eq('Please select a correct answer for all items')
      end
    end
    context 'when only 1 choices are correct' do
      it 'returns "A multiple-choice checkbox item should have more than one correct answer."' do
        items = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '0' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expect(multiple_choice_checkbox.isvalid(items)).to eq('A multiple-choice checkbox item should have more than one correct answer.')
      end
    end
    context 'when 2 choices are correct' do
      it 'returns "valid"' do
        items = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '1' }, '3' => { txt: 'item text', iscorrect: '0' }, '4' => { txt: 'item text', iscorrect: '0' } }
        expect(multiple_choice_checkbox.isvalid(items)).to eq('valid')
      end
    end
  end
  describe '#get_formatted_item_type' do
    it 'returns "Multiple Choice - Checked"' do
      expect(multiple_choice_checkbox.get_formatted_item_type).to eq('Multiple Choice - Checked')
    end
  end
  describe '#compute_item_score' do
    it 'returns 0' do
      expect(Question.compute_item_score).to eq(0)
    end
  end
  describe '#export_fields' do
    it 'returns the column headers' do
      expect(Question.export_fields([])).to eq(['Seq', 'Question', 'Type', 'Weight', 'text area size', 'max_label', 'min_label'])
    end
  end
  describe '#get_all_items_with_comments_available' do
    context 'when the assignment has no itemnaires associated' do
      it 'returns an empty array' do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:itemnaires).and_return([])
        expect(Question.get_all_items_with_comments_available(assignment.id)).to eq([])
      end
    end
    context 'when the assignment has two itemnaires associated, metareview and review, with one scored item' do
      it 'returns an array of the id of the scored item' do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:itemnaires).and_return([itemnaire1, itemnaire2])
        allow(itemnaire1).to receive(:items).and_return([scored_item])
        expect(Question.get_all_items_with_comments_available(assignment.id)).to eq([1])
      end
    end
  end
  describe '#import' do
    context 'when the row length is not 5' do
      it 'throws an error' do
        expect { Question.import(%w[header1 header2 header3], [], [], nil) }.to raise_error(ArgumentError)
      end
    end
    context 'when there is no itemnaire' do
      it 'throws an error' do
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        expect { Question.import(%w[header1 header2 header3 header4 header5], [], [], 1) }.to raise_error(ArgumentError)
      end
    end
  end
  describe '#export' do
    it 'writes to a csv file' do
      csv_1 = []
      allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
      allow(itemnaire1).to receive(:items).and_return([item])
      expect(Question.export(csv_1, 1, nil)).to eq([item])
    end
  end
end
