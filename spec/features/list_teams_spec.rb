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
    require 'pp'
    driver = Selenium::WebDriver.for :firefox
    driver.get("http://127.0.0.1:3000/")
    driver.find_element(:id, "login_name").send_keys("instructor6")
    driver.find_element(:id, "login_password").send_keys("password")
    driver.find_element(:name, "commit").click()
    driver.get("http://127.0.0.1:3000/users/list")

    has_institution = false
    if driver.find_element(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr[2]/th[3]").text == "Institution"
      has_institution = true
      expect(has_institution).to be(true)
    end
    expect(has_institution).to be(true)
  end
end