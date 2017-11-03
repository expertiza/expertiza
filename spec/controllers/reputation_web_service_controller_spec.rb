require 'rspec'

describe ReputationWebServiceController do
  before(:each) do
    user = build(:instructor)
    stub_current_user(user, user.role.name, user.role)
  end

  it 'should do execute query' do
    # controller.json_generator(41,0,2,'peer review grades').should != nil
    has_topic = !SignUpTopic.where(41).empty?
    raw_data_array = controller.db_query(41, 2, has_topic, 0)
    expect(controller.db_query(41, 2, has_topic, 0)).to be_an_instance_of(Array)
    expect(controller.db_query(41, 2, has_topic, 0)).should_not be(nil)
    expect(raw_data_array).should_not be(nil)
  end

  it 'should execute query for quiz score' do
    result = controller.db_query_with_quiz_score(55, 0)
    expect(result).to be_an_instance_of(Array)
    expect(result).should_not be(nil)
    # puts result
  end

end
