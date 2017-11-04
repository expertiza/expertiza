describe 'FeedbackResponseMap' do
  describe '.feedback_response_report' do
    it "should return authors and responses by rounds" do
      @assignment = create(:assignment, id: 1)
      @student1 = create(:student, id: 5, name: "abcd")
      @student2 = create(:student, id: 3, name: "efgh")
      @student3 = create(:student, id: 7, name: "wxyz")
      @student4 = create(:student, id: 8, name: "pqrs")
      @student5 = create(:student, id: 9, name: "lmno")
      @reviewer1 = create(:participant, id: 1, user_id: 5, parent_id: 1)
      @reviewer2 = create(:participant, id: 4, user_id: 8, parent_id: 1)
      @reviewer3 = create(:participant, id: 5, user_id: 9, parent_id: 1)
      @reviewee1 = create(:participant, id: 2, user_id: 3, parent_id: 1)
      @reviewee2 = create(:participant, id: 3, user_id: 7, parent_id: 1)
      @team = create(:assignment_team, id: 2, name: "teamxyz", parent_id: 1)
      @teamuser1 = create(:team_user, team: @team, user: @student2)
      @teamuser2 = create(:team_user, team: @team, user: @student3)
      @review_response_map1 = create(:review_response_map, id: 1, assignment: @assignment, reviewee: @team, reviewer_id: 1)
      @review_response_map2 = create(:review_response_map, id: 2, assignment: @assignment, reviewee: @team, reviewer_id: 4)
      @review_response_map3 = create(:review_response_map, id: 3, assignment: @assignment, reviewee: @team, reviewer_id: 5)
      @response1 = create(:response, id: 1, response_map: @review_response_map1, round: 1)
      @response2 = create(:response, id: 2, response_map: @review_response_map2, round: 2)
      @response3 = create(:response, id: 3, response_map: @review_response_map3, round: 3)
      expect(FeedbackResponseMap.feedback_response_report(1, nil)).to eql [[@reviewee1, @reviewee2], [1, 2, 3]]
    end
  end
end
