describe VmTagPromptAnswer do
  let!(:answer) { create(:answer, comments: 'test comment') }
  let(:tp) { TagPrompt.new(prompt: 'test prompt', desc: 'test desc', control_type: 'Checkbox') }
  let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: 'Criterion', answer_length_threshold: 5 }
  describe '#initialize' do
    it 'creates a tag prompt answer' do
      vm_tag_prompt_answer = VmTagPromptAnswer.new(answer, tp, tag_dep)
      expect(vm_tag_prompt_answer.answer).to eq(answer)
      expect(vm_tag_prompt_answer.tag_prompt).to eq(tp)
      expect(vm_tag_prompt_answer.tag_dep).to eq(tag_dep)
    end
  end
end
