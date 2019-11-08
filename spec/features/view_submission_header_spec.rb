describe "Check if view submission page has header" do
  before(:each) do
    create(:assignment)
  end

  describe "check header has assignment name" do

    it "is able to add a member to an assignment team" do
      login_as('instructor6')
      assignment = Assignment.first
      visit("/assignments/list_submissions?id=#{assignment.id}")
      expect(page).to have_content("#{assignment.name}")
    end
  end
end 