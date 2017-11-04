describe 'ReviewResponseMap' do
  describe '.export' do
    it 'should return an array containing the mapping between reviewee name and reviewer name' do
      @assignment = create(:assignment, id: 1)
      @assignment_team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @student = create(:student, id: 5, name: "abcd")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @review_response_map = create(:review_response_map, assignment: @assignment, reviewee: @assignment_team, reviewer_id: 1)
      expect(ReviewResponseMap.export([], 1, nil)).to eql [@review_response_map]
    end
    it 'should return an array sorted according to revi
ewee name' do
      @assignment = create(:assignment, id: 1)
      @assignment_team1 = create(:assignment_team, id: 2,name: "teamxyz", parent_id: 1)
      @assignment_team2 = create(:assignment_team, id: 3,name: "abcdefg", parent_id: 1)
      @student = create(:student, id: 5, name: "abcd")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @review_response_map1 = create(:review_response_map, assignment: @assignment,reviewee: @assignment_team1, reviewer_id: 1)
      @review_response_map2 = create(:review_response_map, assignment: @assignment,reviewee: @assignment_team2, reviewer_id: 1)
      expect(ReviewResponseMap.export([],1,nil)).to eql [@review_response_map2, @review_response_map1]
    end
  end

  describe '.import' do
    it 'should raise argument error when cannot find name' do
      @assignment = create(:assignment, id: 1)
      @assignment_team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @student = create(:student, id: 5, name: "abcd")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @review_response_map = create(:review_response_map, assignment: @assignment, reviewee: @assignment_team, reviewer_id: 1)
      expect(ReviewResponseMap.import(["aa"],nil,nil,1)).to raise_exception(ArgumentError,"Cannot find reviewee user.")
    end
    it 'should create mappings for the input info' do
      @assignment = create(:assignment, id: 1)
      @student1 = create(:student, id: 5, name: "abcd")
      @student2 = create(:student, id: 3, name: "efgh")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @reviewee = create(:participant, id: 2, user_id: 3, parent_id: 1)
      @team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @teamuser = create(:team_user, team: @team, user: @student2)
      @review_response_map = create(:review_response_map, assignment: @assignment, reviewee: @team, reviewer_id: 1)
      ReviewResponseMap.import(["efgh","abcd"],nil,nil,1)
      expect(ReviewResponseMap.first).to eql @review_response_map
    end
  end
end