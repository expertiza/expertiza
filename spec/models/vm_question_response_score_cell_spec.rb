describe VmQuestionResponseScoreCell do
	let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
	let!(:answer) { create(:answer, answer: 5, comments: "This is a comment. I hope it is a good one") }
	let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
  let(:tp2) { TagPrompt.new(prompt: "test prompt2", desc: "test desc2", control_type: "Slider") }
  let(:id) {create(:id1, id1 : 1)}
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, map_id: 1, response_map: response_map) }
  before(:each) do
    allow(response).to receive(:map).and_return(review_response_map)
  end
  	describe '#initialize' do
  		it 'creates a score cell and its getter functiors work' do
  			color_code_number = ((5.to_f / 5.to_f) * 5.0).ceil
  			color_code = "c#{color_code_number}"
  			vm_tag_prompts = [tp, tp2]
			response_id = id
  			vmqrsc = VmQuestionResponseScoreCell.new(answer.answer, color_code, answer.comments, vm_tag_prompts, response_id)
  			expect(vmqrsc.score_value).to eq(answer.answer)
  			expect(vmqrsc.color_code).to eq(color_code)
  			expect(vmqrsc.comment).to eq(answer.comments)
			expect(vmqrsc.response_id).to eq(response_id)
  			expect(vmqrsc.vm_prompts).to eq(vm_tag_prompts)
  		end
  	end
  	describe '#reviewer_id' do
  		it 'returns reviewer id' do
			allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
			allow(response).to receive(:populate_new_response).with(:review_response_map, "0").and_return(response)
        	expect(response.id).to eq(1)	
		end
	end

end