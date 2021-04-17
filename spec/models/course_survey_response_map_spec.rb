describe CourseSurveyResponseMap do
	let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
	let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 985, name: "course_survey", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
	before(:each) do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: next_day, parent_id: "12345678", type: "CourseSurveyDeployment"
  end
  it { should belong_to :survey_deployment }
  it { should belong_to :course }
  it { should belong_to :reviewer}
end