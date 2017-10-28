describe 'FeedbackResponseMap' do
  before(:each) do
    @feedback_response_map = build(:feedback_response_map,id: 1)
  end
  it "should be vaild" do
    expect(@feedback_response_map).to be_valid
  end
end