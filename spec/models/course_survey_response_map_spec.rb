describe CourseSurveyResponseMap do
  let(:participant) { build(:participant, user_id: 1, user: build(:student, name: 'Jane', fullname: 'Doe, Jane', id: 1)) }
  let(:course_survey_questionnaire) { CourseSurveyQuestionnaire.new id: 985, name: 'course_survey', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:previous_day) { (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:next_day) { (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:user) { build(:student, email: 'expertiza.debugging@gmail.com', name: 'Jane', fullname: 'Doe, Jane', id: 1) }
  let(:course) { build(:course, id: 1, name: 'ECE517') }
  before(:each) do
    survey_deployment = CourseSurveyDeployment.new questionnaire_id: 985, start_date: previous_day, end_date: next_day, parent_id: '12345678', type: 'CourseSurveyDeployment'
    @course_survey_response_map = CourseSurveyResponseMap.new
    @course_survey_response_map.reviewer = participant
    @course_survey_response_map.survey_deployment = survey_deployment
    @course_survey_response_map.course = course
  end

  # test active model associations
  it { should belong_to :survey_deployment }
  it { should belong_to :course }
  it { should belong_to :reviewer }

  describe '#questionnaire' do
    it 'returns the associated course survey questionnaire' do
      allow(Questionnaire).to receive(:find_by).with(id: 985).and_return(course_survey_questionnaire)
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

  describe '#survey?' do
    it 'should return true' do
      expect(@course_survey_response_map.survey?).to eq(true)
    end
  end

  describe '#email' do
    it 'should send an email to the associated user' do
      allow(User).to receive(:find).with(1).and_return(user)
      defn = {
        body: {
          type: 'Peer Review',
          obj_name: 'Test Assgt',
          first_name: 'no one',
          partial_name: 'new_submission'
        },
        to: 'expertiza.debugging@gmail.com'
      }
      email = @course_survey_response_map.email(defn, participant, course)
      expect(email.from[0]).to eq('expertiza.debugging@gmail.com')
      expect(email.to[0]).to eq('expertiza.debugging@gmail.com')
    end
  end
end
