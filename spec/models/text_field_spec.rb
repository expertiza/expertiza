describe 'TextField' do
  let(:tfbb) { TextField.new(txt: 'text field text', break_before: true) }
  let(:tf) { TextField.new(txt: 'text field text', break_before: false) }
  let(:ans) { Answer.new(comments: 'text field comment') }

  describe '#complete' do
    context 'when the answer is nil' do
      before(:each) do
        @tf_html = tf.complete(0, nil)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@tf_html.html_safe?).to be_truthy
      end
      it 'returns an input tag whose type is "text"' do
        expect(@tf_html).to match(/<input/).and match(/type="text"/)
      end
    end

    context 'when the answer is not nil' do
      before(:each) do
        @tf_html = tf.complete(0, ans)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@tf_html.html_safe?).to be_truthy
      end
      it 'returns a text which includes the answer' do
        expect(@tf_html).to match(/<input/).and match(/type="text"/).and include(ans.comments)
      end
    end

    describe '#view_completed_question' do
      context 'when break_before is true' do
        before(:each) do
          @tf_html = tfbb.view_completed_question(0, ans)
        end
        it 'returns an html_safe string to be rendered' do
          expect(@tf_html.html_safe?).to be_truthy
        end
        it 'returns a bold tag with text and comment' do
          expect(@tf_html).to match(/<b/).and include(tfbb.txt).and include(ans.comments)
        end
      end

      context 'when break_before is false' do
        before(:each) do
          @tf_html = tf.view_completed_question(0, ans)
        end
        it 'returns an html_safe string to be rendered' do
          expect(@tf_html.html_safe?).to be_truthy
        end
        it 'returns a string with text and comment' do
          expect(@tf_html).to include(tf.txt).and include(ans.comments)
        end
      end
    end
  end
end
