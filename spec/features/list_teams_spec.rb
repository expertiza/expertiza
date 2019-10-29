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
    visit "/course/new?private=1"
    page.body.should have_selector("select#course_institutions_id option:nth-of-type(0)", text: 'Institution')

    has_institution = false
    if driver.find_element(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr[2]/th[3]").text == "Institution"
      has_institution = true
      expect(has_institution).to be(true)
    end
    expect(has_institution).to be(true)
  end
end