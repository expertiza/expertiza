describe 'TextArea' do
  let(:ta) { TextArea.new(txt: 'text area text') }
  let(:ans) { Answer.new(comments: 'text area comment') }

  context 'when the answer is nil' do
    describe '#complete' do
      before(:each) do
        @ta_html = ta.complete(0, nil)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@ta_html.html_safe?).to be_truthy
      end
      it 'returns a textarea' do
        expect(@ta_html).to match(/<input/).and match(/<textarea/)
      end
    end
  end

  context 'when the answer is not nil' do
    describe '#complete' do
      before(:each) do
        @ta_html = ta.complete(0, ans)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@ta_html.html_safe?).to be_truthy
      end
      it 'returns a text which include the answer' do
        expect(@ta_html).to match(/<input/).and match(/<textarea/).and include(ans.comments)
      end
    end

    describe '#view_completed_question' do
      before(:each) do
        @ta_html = ta.view_completed_question(0, ans)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@ta_html.html_safe?).to be_truthy
      end
      it 'returns a stirng with both the text and the comment' do
        expect(@ta_html).to include(ta.txt).and include(ans.comments)
      end
    end
  end
end
