describe 'MetaReviewResponseMap' do
  describe '#get_all_versions' do
    it 'should return only the associated response' do
      @review_response_map = create(:review_response_map, id: 1)
      @response = create(:response, id: 1, response_map: @review_response_map)
      @metareview_response_map = create(:meta_review_response_map, review_mapping: @review_response_map)
      expect(@metareview_response_map.get_all_versions).to eql [@response]
    end
    it 'should return nil if no association' do
      @review_response_map1 = create(:review_response_map, id: 1)
      @review_response_map2 = create(:review_response_map, id: 2)
      @response = create(:response, id: 1, response_map: @review_response_map2)
      @metareview_response_map = create(:meta_review_response_map, review_mapping: @review_response_map1)
      expect(@metareview_response_map.get_all_versions).to eql []
    end
  end

  describe '.export' do
    it 'should return proper data in csv' do
      @assignment = create(:assignment, id: 1)
      @student1 = create(:student, id: 5, name: "abcd")
      @student2 = create(:student, id: 3, name: "efgh")
      @student3 = create(:student, id: 7, name: "wxyz")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @reviewee = create(:participant, id: 2, user_id: 3, parent_id: 1)
      @metareviewer = create(:participant, id: 3, user_id: 7)
      @team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @teamuser = create(:team_user, team: @team, user: @student2)
      @review_response_map = create(:review_response_map, id: 1, assignment: @assignment, reviewee: @team, reviewer_id: 1)
      @metareview_response_map = create(:meta_review_response_map, review_mapping: @review_response_map, reviewee: @reviewer, reviewer_id: 3)
      expect(MetareviewResponseMap.export([], 1, nil)).to eql [@metareview_response_map]
    end
  end

  describe '.import' do
    it 'should create a metareview_response_map active record object' do
      @assignment = create(:assignment, id: 1)
      @student1 = create(:student, id: 5, name: "abcd")
      @student2 = create(:student, id: 3, name: "efgh")
      @student3 = create(:student, id: 7, name: "wxyz")
      @reviewer = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @reviewee = create(:participant, id: 2, user_id: 3, parent_id: 1)
      @metareviewer = create(:participant, id: 3, user_id: 7)
      @team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @teamuser = create(:team_user, team: @team, user: @student2)
      @review_response_map = create(:review_response_map, id: 1, assignment: @assignment, reviewee: @team, reviewer_id: 1)
      MetareviewResponseMap.import(%w[teamxyz abcd wxyz], nil, 1)
      expect(MetareviewResponseMap.first).not_to eql nil
    end
  end
end
