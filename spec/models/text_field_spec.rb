describe 'TextField' do
  let(:tf) { TextField.new(txt: 'test text') }
  let(:ans) { Answer.new(comments: 'test comment')}

  context 'when the answer is nil' do
    describe '#complete' do
      before (:each) do
        @tf_html = tf.complete(0, nil)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@tf_html.html_safe?).to be_truthy
      end
      it 'returns a text' do
        expect(@tf_html).to match(/<input/).and match(/type="text"/)
      end
    end
  end

  context 'when the answer is not nil' do
    describe '#complete' do
      before (:each) do
        @tf_html = tf.complete(0, ans)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@tf_html.html_safe?).to be_truthy
      end
      it 'returns a text which include the answer' do
        expect(@tf_html).to match(/<input/).and match(/type="text"/).and include(ans.comments)
      end
    end

    describe '#view_completed_question' do
      before (:each) do
        @tf_html = tf.view_completed_question(0, ans)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@tf_html.html_safe?).to be_truthy
      end
      it 'returns a stirng with both the text and the comment' do
        expect(@tf_html).to include(tf.txt).and include(ans.comments)
      end
    end
  end
end
