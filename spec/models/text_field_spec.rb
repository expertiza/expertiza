describe TextField do
  let!(:answer) { create(:answer, comments: 'test comment') }
  describe '#complete' do
    it 'returns html' do
      tf = TextField.new
      tf.txt = 'Field Text'
      tf.size = 35
      html = tf.complete(1, answer)
      expect(html).to eq('<p style="width: 80%;"><label for="responses_1" >Field Text&nbsp;&nbsp;</label><input id="responses_1_score" name="responses[1][score]" type="hidden" value="" "><input id="responses_1_comments" label=Field Text name="responses[1][comment]" style="width: 40%;" size=35 type="text"value="test comment">')
    end
  end
  describe '#view_completed_question' do
    context 'when the type is a TextField and there is a break before' do
      it 'returns html' do
        tf = TextField.new
        tf.txt = 'Field Text'
        tf.size = 35
        tf.type = 'TextField'
        tf.break_before = true
        allow(Question).to receive(:exists?).and_return(false)
        html = tf.view_completed_question(1, answer)
        expect(html).to eq('<b>1. Field Text</b>&nbsp;&nbsp;&nbsp;&nbsp;test comment')
      end
    end
    context 'when the type is a TextField and there is not a break before' do
      it 'returns html' do
        tf = TextField.new
        tf.txt = 'Field Text'
        tf.size = 35
        tf.type = 'TextField'
        tf.break_before = false
        allow(Question).to receive(:exists?).and_return(false)
        html = tf.view_completed_question(1, answer)
        expect(html).to eq('Field Texttest comment<BR/><BR/>')
      end
    end
  end
end
