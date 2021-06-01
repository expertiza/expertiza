describe TextField do
  let!(:answer) { create(:answer, comments: "test comment") }
  describe '#complete' do
    it 'returns html' do
      tf = TextField.new
      tf.txt = 'Field Text'
      tf.size = 35
      html = tf.complete(1, answer)
      expect(html).to eq('')
    end
  end
end