describe TagPromptDeployment do
	let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 5 }
	let(:tag_dep1) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: nil, assignment_id: 1, assignment: assignment , questionnaire: questionaire}
	let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
	let(:team) {Team.new(id: 1)}
	let(:assignment) {Assignment.new(id: 1)}
	let(:questionaire) {Questionnaire.new(id: 1,name: 'question1') }
	let(:rp) {Response.new(map_id: 1, round: 1, additional_comment: "improvement scope") }
	let(:responses) {Response.new(map_id:[1,2], round: [1, 1], additional_comment: ["improvement scope",'through comments']) }
	let(:question) {Question.new(questionnaire_id: 1, type: 'tagging')}
	let(:answers) {Answer.new(id:[1,2,3], question_id:[1,1,1], answer: [3,3,3], comments: ['comment', 'comment is lengthy', 'comment is too lengthy'], response_id: [241, 241, 241])}
	let(:answers_one) {Answer.new(id:[1], question_id:[1], answer: [3], comments: ['comment'], response_id: [241])}

	describe '#tag_prompt' do
		it 'returns the associated tag prompt with the deployment' do
			allow(TagPrompt).to receive(:find).with(1).and_return(tp)
			expect(tag_dep.tag_prompt).to be(tp)
		end
	end
#get_number_of_taggable_answers calculates total taggable answers assigned to an user who participated in "tag review assignment".
	describe '#get_number_of_taggable_answers' do
		before(:each) do
			questions_ids = double(1)
			responses_ids = double(241)
			allow(Team).to receive(:joins).with(:teams_users).and_return(team)
			allow(team).to receive(:where).with(team_users: {parent_id: tag_dep1.assignment_id}, user_id: 1).and_return(team)
			allow(Response).to receive(:joins).with(:response_maps).and_return(responses)
			allow(responses).to receive(:where).with(response_maps: {reviewed_object_id: tag_dep1.assignment.id, reviewee_id: team.id}).and_return(rp)
			allow(rp).to receive(:empty?).and_return(false)
			allow(rp).to receive(:map).with(any_args).and_return(responses_ids)
			allow(Question).to receive(:where).with({questionnaire_id: tag_dep1.questionnaire.id, type: tag_dep1.question_type}).and_return(question)
			allow(question).to receive(:empty?).and_return(false)
			allow(question).to receive(:map).with(any_args).and_return(questions_ids)
			allow(Answer).to receive(:where).with({question_id: questions_ids, response_id: responses_ids}).and_return(answers)
		end
		context "when answer_length_threshold null" do
			it 'count of taggable answers' do
				questions_ids = double(1)
				responses_ids = double(241)
				allow(Answer).to receive(:where).with({question_id: questions_ids, response_id: responses_ids}).and_return(answers)
				allow(answers).to receive(:count)
				expect((tag_dep1.get_number_of_taggable_answers(1))).to eq(answers.count)
			end
		end
		context "when answer_length_threshold NOT null" do
			it 'count of taggable answers less than answers_one' do
				questions_ids = double(1)
				responses_ids = double(241)
				tag_dep1.answer_length_threshold = 15
				allow(Answer).to receive(:where).with({question_id: questions_ids, response_id: responses_ids}).and_return(answers)
				allow(answers).to receive(:where).with(conditions: "length(comments) < #{tag_dep1.answer_length_threshold}").and_return(answers_one)
				allow(answers_one).to receive(:count)
				expect((tag_dep1.get_number_of_taggable_answers(1))).to eq(answers_one.count)
			end
    end
		context "when responses empty" do
			it "count of taggable answers zero" do
				allow(rp).to receive(:empty?).and_return(true)
				expect((tag_dep1.get_number_of_taggable_answers(1))).to eq(0)
			end
		end
		context "when questions empty" do
			it "count of taggable answers zero" do
				allow(question).to receive(:empty?).and_return(true)
				expect((tag_dep1.get_number_of_taggable_answers(1))).to eq(0)
			end
		end
  end
end
