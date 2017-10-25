describe 'Response Map' do
  before(:each) do
    @response_map = build(:response_map,id: 1)
  end

  #check for validity - always true as no validation in model
  it "should be vaild" do
    expect(@response_map).to be_valid
  end

  #returns id when map_id is called
  describe '#map_id' do
    it 'should return the id' do
      expect(@response_map.map_id).to be == 1
    end
  end


  describe '.get_assessments_for' do
    let(:team1) { Team.new name: 'team1',id: 1, parent_id: 1, type: nil }
    it 'should return the responses given to them by all the reviewers' do
      @response_map1 = build(:response_map, id: 1, reviewer_id: 1, reviewee_id: team1.id, type: "ReviewResponseMap")
      @response_map2 = build(:response_map, id: 2, reviewer_id: 2, reviewee_id: team1.id, type: "ReviewResponseMap")
      @response1 = build(:response, id: 1, response_map: @response_map1, is_submitted: true)
      @response2 = build(:response, id: 2,response_map: @response_map2, is_submitted: true)
      expect(ResponseMap.get_assessments_for(team1)).to eql [@response1,@response2]
    end
  end
end