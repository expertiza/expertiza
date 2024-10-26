describe TrueFalse do
  let(:true_false) { build(:true_false, id: 1) }
  describe '#edit' do
    it 'returns html' do
      qc1 = double('QuizQuestionChoice')
      qc2 = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).with(item_id: 1).and_return([qc1, qc2])
      allow(qc1).to receive(:iscorrect).and_return(true)
      allow(qc2).to receive(:iscorrect).and_return(false)
      expect(true_false.edit).to eq('<tr><td><textarea cols="100" name="item[1][txt]" id="item_1_txt">Test item:</textarea></td></tr><tr><td>Question Weight: <input type="number" name="item_weights[1][txt]" id="item_wt_1_txt" value="1" min="0" /></td></tr><tr><td><input type="radio" name="quiz_item_choices[1][TrueFalse][1][iscorrect]" id="quiz_item_choices_1_TrueFalse_1_iscorrect_True" value="True" checked="checked" />True</td></tr><tr><td><input type="radio" name="quiz_item_choices[1][TrueFalse][1][iscorrect]" id="quiz_item_choices_1_TrueFalse_1_iscorrect_True" value="False" />False</td></tr>')
    end
  end
  describe '#isvalid' do
    context 'when the item does not have text' do
      it 'returns "Please make sure all items have text"' do
        allow(true_false).to receive(:txt).and_return('')
        items = { '1' => { txt: 'item text', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '0' } }
        expect(true_false.isvalid(items)).to eq('Please make sure all items have text')
      end
    end
    context 'when the choice does not have text' do
      it 'returns "Please make sure every item has text for all options"' do
        allow(true_false).to receive(:txt).and_return('Text')
        items = { '1' => { txt: '', iscorrect: '1' }, '2' => { txt: 'item text', iscorrect: '0' } }
        expect(true_false.isvalid(items)).to eq('Please make sure every item has text for all options')
      end
    end
    context 'when no right answer was selected' do
      it 'returns "Please select a correct answer for all items"' do
        allow(true_false).to receive(:txt).and_return('Text')
        items = { '1' => { txt: 'item text', iscorrect: '0' }, '2' => { txt: 'item text', iscorrect: '0' } }
        expect(true_false.isvalid(items)).to eq('Please select a correct answer for all items')
      end
    end
  end
  describe '#get_formatted_item_type' do
    it 'returns "True/False"' do
      expect(true_false.get_formatted_item_type).to eq('True/False')
    end
  end
end
