describe CourseSurveyResponseMap do
	let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
	let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 985, name: "course_survey", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
	let(:previous_day) { (Time.now.getlocal - 1 * 86_400).strftime("%Y-%m-%d %H:%M:%S") }
  let(:next_day) { (Time.now.getlocal + 1 * 86_400).strftime("%Y-%m-%d %H:%M:%S") }
  let(:course) { build(:course)}
	before(:each) do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: next_day, parent_id: "12345678", type: "CourseSurveyDeployment"
    @course_survey_response_map = CourseSurveyResponseMap.new
    @course_survey_response_map.reviewer = participant
    @course_survey_response_map.survey_deployment = survey_deployment
    @course_survey_response_map.course = course

  end

  # test active model associations
  it { should belong_to :survey_deployment }
  it { should belong_to :course }
  it { should belong_to :reviewer}

  describe '#questionnaire' do
  	it 'returns the associated course survey questionnaire' do
  		allow(Questionnaire).to receive(:find_by).with( {:id => 985} ).and_return(course_survey_questionnaire)
  		expect(@course_survey_response_map.questionnaire).to eq(course_survey_questionnaire)
  	end
  end

  describe '#contribute' do
  	it 'returns nil until it is implemented' do
  		expect(@course_survey_response_map.contributor).to eq(nil)
  	end
  end

  describe '#survey_parent' do
  	it 'returns the course associated with the course_survey_response_map' do
  		expect(@course_survey_response_map.survey_parent).to eq(course)
  	end
  end

  describe '#get_title' do
  	it 'returns Course Survey' do
  		expect(@course_survey_response_map.get_title).to eq('Course Survey')
  	end
  end

  #tests for the inherited super class
  describe '#survey?' do
    it 'should return true' do
      expect(@assignment_survey_response_map.survey?).to eq(true)
    end
  end
end