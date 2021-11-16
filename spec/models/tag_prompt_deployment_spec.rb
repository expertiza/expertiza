describe TagPromptDeployment do
	let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 5 }
	let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }

	let(:team) {Team.new(id: 1, parent_id: 1)}
	let(:response) {Response.new(id: 1)}
	# let(:resp) {Response.new(id: 1, round: 1, additional_comment: "improvement scope")}
  let(:responses) {Response.new(id: 1, round: 1, additional_comment: "improvement scope")}
	let(:assignment) {Assignment.new({assignment: 1})}
	let(:question) {Question.new(questionnaire_id: 1, type: 'tagging')}


	describe '#tag_prompt' do
		it 'returns the associated tag prompt with the deployment' do
			allow(TagPrompt).to receive(:find).with(1).and_return(tp)
			expect(tag_dep.tag_prompt).to be(tp)
		end
	end



  # get_number_of_taggable_answers calculates total taggable answers assigned to an user who  participated in "tag review assignment".
	describe '#get_number_of_taggable_answers' do
    context "when team has no review" do
			it 'get response for each taggable question' do
				allow(Team).to receive(:join).with(:team_users, {:parent_id => 1, :user_id => 1}).and_return(team.id)
				allow(Response).to receive(:join).with(:response_maps, {:reviewed_object_id => 1, :reviewee_id => team.id}).and_return(response.id)
				expect(response.id).to be(responses.id)
			end
			it "get question for each taggable question" do
				# questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)
				allow(Question).to receive(:where).with({:questionnaire_id => 1, :type => 'tagging'}).and_return(question)
				expect(question).not_to be(nil)
      end
    end
  end



end
