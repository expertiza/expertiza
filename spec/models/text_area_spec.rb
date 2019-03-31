describe 'TextArea' do
  let(:cols) { '60' }
  let (:rows) { '50' }
  let(:ta_nil_size) { TextArea.new(txt: 'text area text', size: nil) }
  let(:ta_size) { TextArea.new(txt: 'text area text', size: cols+','+rows) }
  let(:ans) { Answer.new(comments: 'text area comment') }

  describe '#complete' do
    context 'when the answer is nil' do
      before(:each) do
        @ta_html = ta_size.complete(0, nil)
      end
      it 'returns an html_safe string to be rendered' do
        expect(@ta_html.html_safe?).to be_truthy
      end
      it 'returns an input tag' do
        expect(@ta_html).to match(/<input/)
      end
      it 'returns a textarea tag of specified size' do
        expect(@ta_html).to match(/<textarea/).and include('rows="'+rows).and include('cols="'+cols)
      end
    end

    context 'when the answer is not nil' do
      before(:each) do
        @ta_html = ta_size.complete(0, ans)
      end
      it 'returns a textarea tag which includes the answer' do
        expect(@ta_html).to match(/<textarea/).and include(ans.comments)
      end
    end

    context 'when the size is not specified' do
      before(:each) do
        @ta_html = ta_nil_size.complete(0, ans)
      end
      it 'returns a textarea tag with 70 cols and 1 row' do
        expect(@ta_html).to match(/<textarea/).and match(/rows="1"/).and match(/cols="70"/)
      end
    end
  end

  describe '#view_completed_question' do
    before(:each) do
      @ta_html = ta_size.view_completed_question(0, ans)
    end
    it 'returns an html_safe string to be rendered' do
      expect(@ta_html.html_safe?).to be_truthy
    end
    it 'returns a string with both the text and the comment' do
      expect(@ta_html).to include(ta_size.txt).and include(ans.comments)
    end
  end
end
