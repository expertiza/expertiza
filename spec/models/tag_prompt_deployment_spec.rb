describe TagPromptDeployment do
	let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 5 }
	let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
	describe '#tag_prompt' do
		it 'returns the associated tag prompt with the deployment' do
			allow(TagPrompt).to receive(:find).with(1).and_return(tp)
			expect(tag_dep.tag_prompt).to be(tp)
		end
	end
end