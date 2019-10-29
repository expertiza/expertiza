describe 'List Team' do
  it 'should list all team nodes' do
    create(:assignment)
    create(:assignment_node)
    assignment_team = create(:assignment_team)
    create(:team_user)

    login_as("instructor6")
    visit '/teams/list?id=1&type=Assignment'

    page.all('#theTable tr').each do |tr|
      expect(tr).to have_content?(assignment_team.name)
    end
  end
end

describe "View users" do
  it "check if instructors show their institutions on the same line as their new feature" do
    create(:superadmin, name: 'super_administrator2')
    login_as('super_administrator2')
    visit "/users/list"
    expect(page.has_content?("Institution")).to eq(true)

  end
end