describe SampleReviewsController do
    it "should redirect to home when anonymous user tries to view all sample reviews" do
		params = {id: 1}
		user = build(:student)
		stub_current_user(nil, user.role.name, user.role)
		get "index", params
		expect(response).to redirect_to("/")
    end
    it "should redirect to home when anonymous user tries to view details of one sample review" do
		params = {id: 1}
		user = build(:student)
		stub_current_user(nil, user.role.name, user.role)
		get "show", params
		expect(response).to redirect_to("/")
    end
    it "should redirect to sample reviews when a particular review with 'Not a Sample' status is passed" do
		user = build(:instructor)
		stub_current_user(user, user.role.name, user.role)
		response = build(:response)
		params = {id: response.id}
		get "show", params
		expect(response).to redirect_to("/")
	end
end