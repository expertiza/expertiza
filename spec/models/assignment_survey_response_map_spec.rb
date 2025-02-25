describe AssignmentSurveyResponseMap, type: :model do
  let(:participant) { build(:participant, user_id: 1, user: build(:student, username: 'Jane', name: 'Doe, Jane', id: 1)) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let(:previous_day) { (Time.now.getlocal - 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:next_day) { (Time.now.getlocal + 1 * 86_400).strftime('%Y-%m-%d %H:%M:%S') }
  let(:assignment) { build(:assignment, id: 1, name: 'Assignment1') }
  let(:user) { build(:student, email: 'expertiza.debugging@gmail.com', username: 'Jane', name: 'Doe, Jane', id: 1) }
  before(:each) do
    survey_deployment = AssignmentSurveyDeployment.new questionnaire_id: 1, start_date: previous_day, end_date: next_day, parent_id: '12345678', type: 'AssignmentSurveyDeployment'
    @assignment_survey_response_map = AssignmentSurveyResponseMap.new
    @assignment_survey_response_map.reviewer = participant
    @assignment_survey_response_map.survey_deployment = survey_deployment
    @assignment_survey_response_map.assignment = assignment
  end

  # test active model associations
  it { should belong_to :survey_deployment }
  it { should belong_to :assignment }
  it { should belong_to :reviewer }

  describe '#questionnaire' do
    it 'returns the associated assignment survey questionnaire' do
      allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(assignment_questionnaire1)
      expect(@assignment_survey_response_map.questionnaire).to eq(assignment_questionnaire1)
    end
  end

  describe '#contribute' do
    it 'returns nil until it is implemented' do
      expect(@assignment_survey_response_map.contributor).to eq(nil)
    end
  end

  describe '#survey_parent' do
    it 'returns the assignment associated with the assignment_survey_response_map' do
      expect(@assignment_survey_response_map.survey_parent).to eq(assignment)
    end
  end

  describe '#get_title' do
    it 'returns Assignment Survey' do
      expect(@assignment_survey_response_map.get_title).to eq('Assignment Survey')
    end
  end

  # tests for the inherited super class
  describe '#survey?' do
    it 'should return true' do
      expect(@assignment_survey_response_map.survey?).to eq(true)
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
      email = @assignment_survey_response_map.email(defn, participant, assignment)
      expect(email.from[0]).to eq('expertiza.mailer@gmail.com')
      expect(email.to[0]).to eq('expertiza.mailer@gmail.com')
    end
  end
end
