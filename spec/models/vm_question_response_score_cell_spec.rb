describe VmQuestionResponseScoreCell do
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let!(:answer) { create(:answer, answer: 5, comments: 'This is a comment. I hope it is a good one') }
  let(:tp) { TagPrompt.new(prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox') }
  let(:tp2) { TagPrompt.new(prompt: 'test prompt2', desc: 'test desc2', control_type: 'Slider') }
  describe '#initialize' do
    it 'creates a score cell and its getter functiors work' do
      color_code_number = ((5.to_f / 5.to_f) * 5.0).ceil
      color_code = "c#{color_code_number}"
      vm_tag_prompts = [tp, tp2]
      vmqrsc = VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments, vm_tag_prompts)
      expect(vmqrsc.score_value).to eq(answer.answer)
      expect(vmqrsc.color_code).to eq(color_code)
      expect(vmqrsc.comment).to eq(answer.comments)
      expect(vmqrsc.vm_prompts).to eq(vm_tag_prompts)
    end
  end
end
