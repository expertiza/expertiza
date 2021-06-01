describe TextField do
  let!(:answer) { create(:answer, comments: "test comment") }
  describe '#complete' do
    it 'returns html' do
      tf = TextField.new
      tf.txt = 'Field Text'
      tf.size = 35
      html = tf.complete(1, answer)
      expect(html).to eq('<p style="width: 80%;"><label for="responses_1" >Field Text&nbsp;&nbsp;</label><input id="responses_1_score" name="responses[1][score]" type="hidden" value="" "><input id="responses_1_comments" label=Field Text name="responses[1][comment]" style="width: 40%;" size=35 type="text"value="test comment">'')
    end
  end
end