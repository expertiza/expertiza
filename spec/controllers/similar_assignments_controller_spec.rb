describe SimilarAssignmentsController do
  describe "perform user validation" do
    it "should redirect to assignments page when a student tries to fetch similar assignments" do
      params = {id: 1}
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "get", params
      expect(response).to redirect_to('/student_task/list')
    end
    it "should redirect to assignments page when a student tries to update any similar assignment" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "update"
      expect(response).to redirect_to('/student_task/list')
    end
  end
  describe "perform basic html validation" do
    it "should give content-type as text/html" do
      params = {id: 1}
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "get", params
      response.header['Content-Type'].should include 'text/html'
    end
  end
end


