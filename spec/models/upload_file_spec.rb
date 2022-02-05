describe 'UploadFile' do
  let(:uf) { UploadFile.new id: 1, type: 'UploadFile', seq: 1.0, txt: 'test txt', weight: 1 }

  describe '#edit' do
    it 'returns the html ' do
      html = uf.edit(0).to_s
      expect(html).to eq('<tr><td align="center"><a rel="nofollow" data-method="delete" href="/questions/1">Remove</a></td><td><input size="6" value="1.0" name="question[1][seq]" id="question_1_seq" type="text"></td><td><textarea cols="50" rows="1" name="question[1][txt]" id="question_1_txt" placeholder="Edit question content here">test txt</textarea></td><td><input size="10" disabled="disabled" value="UploadFile" name="question[1][type]" id="question_1_type" type="text"></td><td><!--placeholder (UploadFile does not need weight)--></td></tr>')
    end
  end

  describe '#view_question_text' do
    it 'returns the html ' do
      html = uf.view_question_text.to_s
      expect(html).to eq('<TR><TD align="left"> test txt </TD><TD align="left">UploadFile</TD><td align="center">1</TD><TD align="center">&mdash;</TD></TR>')
    end
  end
end
