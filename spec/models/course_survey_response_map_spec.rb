describe CourseSurveyResponseMap do
	let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
	let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 985, name: "course_survey", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
	let(:previous_day) { (Time.now.getlocal - 1 * 86_400).strftime("%Y-%m-%d %H:%M:%S") }
  let(:next_day) { (Time.now.getlocal + 1 * 86_400).strftime("%Y-%m-%d %H:%M:%S") }
  let(:course) { build(:course)}
	before(:each) do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: next_day, parent_id: "12345678", type: "CourseSurveyDeployment"
    course_survey_response_map = CourseSurveyResponseMap.new
    course_survey_response_map.reviewer = participant
    course_survey_response_map.survey_deployment = survey_deployment
    course_survey_response_map.course = course

  end

  # test active model associations
  it { should belong_to :survey_deployment }
  it { should belong_to :course }
  it { should belong_to :reviewer}

  describe '#questionnaire' do
  	it 'returns the associated course survey questionnaire' do
  		allow(Questionnaire).to receive(:find_by).with(985).and_return(:course_survey_questionnaire)
  		expect(course_survey_response_map.questionnaire).to_eq(course_survey_questionnaire)
  	end
  end
end