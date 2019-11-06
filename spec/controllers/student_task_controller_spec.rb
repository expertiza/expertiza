require 'rails_helper'

#So far, the purpose of this controller is strictly to test functionality in E1953:
#http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_E1953._Tagging_report_for_student
describe StudentTaskController do
  #Copied from grades_controller_spec.rb
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  #Multiple questions for proper testing of tags
  let(:question1) { build(:question, id: 1, type: "normal") }
  let(:question2) { build(:question, id: 2, type: "normal") }
  
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question1, question2]) }
  let(:student) { build(:student) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [student]) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1, team: team) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  
  #Added for E1953
  #These are tag prompts for quesitons
  let(:tag_prompt1) {build(:tag_prompt, prompt: "Good?", control_type: "slider")}
  let(:tag_prompt2) {build(:tag_prompt, prompt: "Medium?", control_type: "slider")}
  let(:tag_prompt3) {build(:tag_prompt, prompt: "Great?", control_type: "slider")}
  let(:tag_prompt4) {build(:tag_prompt, prompt: "Bad?", control_type: "checkbox")}
  
  #The maps from tag prompts to questionnaires
  let(:deployment1) {build(:tag_prompt_deployment, tag_prompt: tag_prompt1, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment2) {build(:tag_prompt_deployment, tag_prompt: tag_prompt2, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment1) {build(:tag_prompt_deployment, tag_prompt: tag_prompt3, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  let(:deployment2) {build(:tag_prompt_deployment, tag_prompt: tag_prompt4, assignment: assignment, 
                           questionnaire: review_questionnaire, question_type: "normal")}
  
  #This method so far, only tests functionality added in E1953
  describe '#view' do
    before(:each) do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
      allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
      allow(review_questionnaire).to receive(:used_in_round).and_return(0)
    end
  end
end
