describe ReputationWebServiceController do

  before(:each) do
    user = build(:instructor)
    stub_current_user(user, user.role.name, user.role)
  end

  it 'should calculate peer review grades' do
    has_topic = !SignUpTopic.where(45).empty?
    raw_data_array = []
    review_responses = controller.get_review_responses(45, 0)
    raw_data_array = controller.calculate_peer_review_grades(has_topic, review_responses, 0)
    expect(controller.calculate_peer_review_grades(has_topic, review_responses, 0)).to be_an_instance_of(Array)
    expect(raw_data_array).to_not eq(nil)
  end

  it 'should calculate quiz scores' do
    result = controller.calculate_quiz_scores(52,0)
    expect(result).to be_an_instance_of(Array)
    expect(result).to_not eq(nil)
    puts result
  end

end
