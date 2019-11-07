#So far, the purpose of this controller is strictly to test functionality in E1953:
#http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_E1953._Tagging_report_for_student
describe StudentTaskController do
  #Copied from grades_controller_spec.rb
  
  let(:review_response) { build(:response, id: 1) }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  #Multiple questions for proper testing of tags
  let(:question1) { build(:question, id: 1, type: "normal") }
  let(:question2) { build(:question, id: 2, type: "normal") }
  
  let(:answer1) { build(:answer, id: 1, question_id: 1)}
  let(:answer2) { build(:answer, id: 2, question_id: 2)}
  
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question1, question2], type: "ReviewQuestionnaire") }
  let(:student) { build(:student, id: 1) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [student]) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:student_task) { StudentTask.new(participant: participant, assignment: assignment,) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  
  #Added for E1953
  #These are tag prompts for quesitons
  let(:tag_prompt1) {TagPrompt.new(id: 1, prompt: "Good?", control_type: "slider")}
  let(:tag_prompt2) {TagPrompt.new(id: 2, prompt: "Bad?", control_type: "slider")}
  let(:tag_prompt3) {TagPrompt.new(id: 3, prompt: "Okay?", control_type: "slider")}
  let(:tag_prompt4) {TagPrompt.new(id: 4, prompt: "Very Bad?", control_type: "checkbox")}
  
  #The maps from tag prompts to questionnaires
  let(:deployment1) {TagPromptDeployment.new(id: 1, tag_prompt: tag_prompt1, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment2) { TagPromptDeployment.new(id: 2, tag_prompt: tag_prompt2, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment3) { TagPromptDeployment.new(id: 3, tag_prompt: tag_prompt3, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment4) { TagPromptDeployment.new(id: 4, tag_prompt: tag_prompt4, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  
  #This method so far, only tests functionality added in E1953
  describe '#view' do
    before(:each) do
      #Login as a user
      stub_current_user(instructor, instructor.role.name, instructor.role)
      
      allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: 1, user_id: 1, answer: 1).and_return([])
      
      allow(StudentTask).to receive(:from_participant_id).with("1").and_return(student_task)
      
      allow(AssignmentParticipant).to receive(:find).with("1").and_return(participant)
      
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
      
      allow(Question).to receive(:find).with(1).and_return(question1)
      allow(Question).to receive(:find).with(2).and_return(question2)
      
      allow(Answer).to receive(:where).with(response_id: 1).and_return([answer1, answer2])
      
      allow(question1).to receive(:questionnaire).and_return(review_questionnaire)
      allow(question2).to receive(:questionnaire).and_return(review_questionnaire)
      
      allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
      allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
      
      allow(participant).to receive(:team).and_return(team)
      
      allow(team).to receive(:participants).and_return([participant])
      
      allow(review_questionnaire).to receive(:used_in_round).and_return(0)
      
      allow(TagPrompt).to receive(:find).with(1).and_return(tag_prompt1)
      allow(TagPrompt).to receive(:find).with(1).and_return(tag_prompt2)
      allow(TagPrompt).to receive(:find).with(1).and_return(tag_prompt3)
      allow(TagPrompt).to receive(:find).with(1).and_return(tag_prompt4)
      
      allow(TagPromptDeployment).to receive(:where).with(questionnaire_id: 1, assignment_id: 1).and_return([deployment1, deployment2, deployment3, deployment4])
    end
    context 'does a context help' do
      it "reports zero required tags correctly" do
        params = {id: 1}
        get :view, params
        # expect(response).to have_http_status(302)
        # expect(response).to render_template(:view)
        expect(controller.instance_variable_get(:@participant)).to eq(participant)
        expect(assigns(:completed_tags)).to eq(0)
        expect(assigns(:total_tags)).to eq(6)
      end
    end
  end
end
