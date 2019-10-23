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
  before(:each) do
    @user1 =  User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
                       email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle'
    @user1.save
  end

  it "check if instructors show their institutions on the same line as their new feature" do
    require 'pp'
    driver = Selenium::WebDriver.for :firefox
    driver.get("http://localhost:3000/")
    driver.find_element(:id, "login_name").send_keys("instructor6")
    driver.find_element(:id, "login_password").send_keys("password")
    driver.find_element(:name, "commit").click()
    driver.get("http://localhost:3000/users/list")

    has_institution = false
    if driver.find_element(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr[2]/th[3]").text == "Institution"
      has_institution = true
      driver.find_elements(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr").each.with_index(3) do |_,index|
        user_name = driver.find_element(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr[#{index}]/td[1]").text
        pp user_name
        pp User.where(["name LIKE ?", "#{"student"}%"])
        pp User.find_by_id(index.to_i)
        # this_ins = driver.find_element(xpath: "/html/body/div[1]/div[1]/div/div/div/div/table/tbody/tr[#{index}]/td[3]").text
        # that_ins = Institution.find(User.find_by(:name => user_name).institution_id)
        # pp that_ins
        # if (this_ins != "" or that_ins != nil) and this_ins != that_ins
        #   pp user_name
        #   pp this_ins
        #   pp that_ins
        #   has_institution = false
        # end
      end
      expect(has_institution).to be(true)
    end
    expect(has_institution).to be(true)
  end
end