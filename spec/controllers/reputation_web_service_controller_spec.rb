require 'rspec'

describe ReputationWebServiceController do

  before(:each) do
    user = build(:instructor)
    stub_current_user(user, user.role.name, user.role)
    request.env['HTTP_REFERER'] = 'www.google.com'
  end

  it 'should do execute query' do
    #controller.json_generator(41,0,2,'peer review grades').should != nil
    has_topic = !SignUpTopic.where(41).empty?
    raw_data_array = []
    raw_data_array = controller.db_query(41,2,has_topic,0)
    expect(controller.db_query(41,2,has_topic,0)).to be_an_instance_of(Array)
    expect(controller.db_query(41,2,has_topic,0)).should_not be(nil)
    expect(raw_data_array).should_not be(nil)
  end

   it 'should do special query with quiz score' do
    #controller.json_generator(41,0,2,'peer review grades').should != nil
    raw_data_array = []
    raw_data_array = controller.db_query_with_quiz_score(41,0)    
    expect(controller.db_query_with_quiz_score(41,0)).to be_an_instance_of(Array)
    expect(controller.db_query_with_quiz_score(41,0)).should_not be(nil)
    expect(raw_data_array).should_not be(nil)
  end
 
  it 'should query the QuizQuestionnaire with team_ids' do
    team_ids = 1
    quiz_questionnnaire_ids = []
    allow( QuizQuestionnaire).to where(:team_id).and_return(quiz_questionnnaires)
    expect(quiz_questionnnaires).should_not be(nil)
  end 
  
  it 'should get the quiz score' do
      allow(Participant).to find(:reviewer_id).and_return(participant)
      expect(participant).should_not be(nil)
      allow(Participant).to find(:response_map).and_return(quiz_score)
      expect(quiz_score).should_not be(nil)   
  end
  
end
