describe TextArea do
  let(:text_area) { create(:text_area) }
  let!(:answer) { create(:answer, comments: 'test comment') }
  describe '#complete' do
    context 'when the size is nil' do
      it 'uses a default size and returns html' do
        allow(text_area).to receive(:size).and_return(nil)
        html = text_area.complete(1, nil)
        expect(html).to eq('<p><label for="responses_1">Test question:</label></p><input id="responses_1_score" name="responses[1][score]" type="hidden" value=""><p><textarea cols="70" rows="1" id="responses_1_comments" name="responses[1][comment]" class="tinymce"></textarea></p>')
      end
    end
    context 'when the size is set' do
      it 'uses that size and returns html' do
        allow(text_area).to receive(:size).and_return('1,1')
        html = text_area.complete(1, nil)
        expect(html).to eq('<p><label for="responses_1">Test question:</label></p><input id="responses_1_score" name="responses[1][score]" type="hidden" value=""><p><textarea cols="1" rows="1" id="responses_1_comments" name="responses[1][comment]" class="tinymce"></textarea></p>')
      end
    end
  end
  describe '#view_completed_questions' do
    it 'return html' do
      html = text_area.view_completed_question(1, answer)
      expect(html).to eq('<b>1. Test question:</b><BR/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;test comment<BR/><BR/>')
    end
  end
end
