describe ReputationWebServiceController do
  let(:team){build(:assignment_team, id:1)}
  describe '' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day, submitter_count: 0, num_reviews: 3, staggerred_deadline: false, rounds_of_reviews: 2, reputation_algorithm: 'lauw')

      @reviewer_1 = create(:participant, can_review: 1)
      @reviewer_2 = create(:participant, can_review: 1)
      @reviewer_3 = create(:participant, can_review: 1)
      @reviewer_4 = create(:participant, can_review: 1)
      @reviewer_5 = create(:participant, can_review: 1)

      @reviewee = create(:assignment_team, assignment: @assignment)

      @response_map = create(:review_response_map, reviewer: @reviewer)
      @submission_records = create(:submission_records, assignment_id: @assignment.id, team_id: @reviewee.id, operation: 'Submit Hyperlink' content: 'weblink')

    end

    it '' do
      create()
    end
