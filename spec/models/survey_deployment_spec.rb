require 'rspec'

describe 'SurveyDeployment' do
  let(:assgt_survey_questionnaire) { AssignmentSurveyQuestionnaire.new id: 986, name: 'assgt_survey', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 985, name: 'course_survey', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:previous_day) { (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:next_day) { (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:response_map) { build(:review_response_map, reviewer_id: 2) }
  it 'should do check the start and end time' do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: next_day, parent_id: '12345678', type: 'CourseSurveyDeployment'
    expect(survey_deployment).to be_valid
  end

  it 'should not be valid if start time is missing' do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: nil, end_date: next_day, parent_id: '12345678', type: 'CourseSurveyDeployment'
    expect(survey_deployment).not_to be_valid
  end

  it 'should not be valid if end time is missing' do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: nil, parent_id: '12345678', type: 'CourseSurveyDeployment'
    expect(survey_deployment).not_to be_valid
  end

  describe '#response_maps' do
    it 'should return the associated response map' do
      survey_deployment = AssignmentSurveyDeployment.new(questionnaire_id: 986, start_date: previous_day, end_date: nil, parent_id: '12345678', type: 'AssignmentSurveyDeployment', id: 1)
      allow(AssignmentSurveyResponseMap).to receive(:where).with(reviewee_id: 1).and_return([response_map])
      expect(survey_deployment.response_maps).to eq([response_map])
    end
  end
end
