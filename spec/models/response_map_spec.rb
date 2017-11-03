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
    let(:team) { Team.create name: 'team',id: 2, parent_id: 1, type: "AssignmentTeam" }
    it 'should return the responses given to them by all the reviewers' do
      @response_map1 = create(:response_map, id: 1, reviewer_id: 5, reviewed_object_id: 1, reviewee_id: 2, type: "ReviewResponseMap")
      @response1 = create(:response, id: 1, map_id: 1, is_submitted: true)
      expect(ResponseMap.get_assessments_for(team)).to eql [@response1]
    end
  end

  describe '.get_reviewer_assessments_for' do
    let(:team) { Team.create name: 'team',id: 2, parent_id: 1, type: "AssignmentTeam" }
    it 'should return the responses given to the team by the reviewer' do
      @reviewer = create(:student,id: 5)
      @response_map1 = create(:response_map, id: 1, reviewer_id: 5, reviewed_object_id: 1, reviewee_id: 2, type: "ReviewResponseMap")
      @response1 = create(:response, id: 1, map_id: 1, is_submitted: true)
      expect(ResponseMap.get_reviewer_assessments_for(team,@reviewer)).to eql @response1
    end
  end

  describe '#survey' do
    it 'should return false survey' do
      expect(@response_map.survey?).to eql (false)
    end
  end

  #checks if delete mappings can take an empty array
  describe '.delete_mappings' do
    it 'should return failed count zero' do
      mappings=Array.new
      expect(ResponseMap.delete_mappings(mappings,nil)).to eql (0)
    end
  end

end