describe 'FeedbackResponseMap' do
  before(:each) do
    @feedback_response_map = build(:feedback_response_map,id: 1)
    @assignment=build(:assignment,)
  end
  it "should be vaild" do
    expect(@feedback_response_map).to be_valid
  end

  #it "should be valid assignment" do
   # expect(@feedback_response_map.assignment).to must_be_empty
 # end

  it "should return title" do
    #expect (@feedback_response_map.get_title).to eql"Feedback"
    expect @feedback_response_map.get_title.should == "Feedback"
  end


  it "should return test show review" do
    #expect (@feedback_response_map.get_title).to eql"Feedback"
    expect @feedback_response_map.show_review.should == "No review was performed"
  end
end