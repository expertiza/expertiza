describe StudentReviewController do
  context 'logged in as metareviewer' do
    let(:review) { Response.create(map_id: 1, additional_comment: 'hello', round: 1) }
    let(:map) { FeedbackResponseMap.create(reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
    let(:assignment) { AssignmentParticipant.new }
    let(:responsemap) { ResponseMap.new }

    describe "GET #authorFeedback" do
      it 'returns authors feedback' do
        get :show_authors_Feedback
        expect(response).to redirect_to(request.env['HTTP_REFERER'] ? :back : :root)
      end
    end
  end
end
