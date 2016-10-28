require 'rails_helper'

#case1 team leader can invite a student to join team, and a student can accept the invitation

describe "team functionality testing case 1", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
    end

    #case1 team leader can invite a student to join team, and a student can accept the invitaion
  it "case1" do

    in_browser(:one) do

    #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



    #expect(page).to have_content "Welcome!"
    #expect(page).to have_content "Assignments"
    #click_link "Assignments"


    expect(page).to have_content "User: student2064"
    expect(page).to have_content "TestTeam"

    click_link "TestTeam"
    expect(page).to have_content "Signup sheet"
    expect(page).to have_content "Your team"

    #test if the topic can be seen and chosen by a student

    click_link "Signup sheet"
    expect(page).to have_content "work1"
    my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
    my_link.click


     #test after selecting a topic, a team formed
    click_link "Assignments"

    click_link "TestTeam"

    expect(page).to have_content "Your team"

    click_link "Your team"
    expect(page).to have_content "Team Name"
    expect(page).to have_content "student2064"


    #test if a team leader can invite another student



    page.fill_in 'user_name', :with => 'student2065'

    click_button('Invite')

    expect(page).to have_content "Sent invitations"
    expect(page).to have_content "student2065"





      #Capybara.reset_sessions!


    #visit root_path
    #expect(page).to have_content "User Name"
    end



    in_browser(:two) do



    #click_link('Home')
    #click_link('Logout')
    visit '/'
    #save_and_open_page



    #login as student2065

    user = User.find_by_name('student2065')
    msg = user.to_yaml
    File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

    visit root_path
    fill_in 'login_name', with: 'student2065'
    fill_in 'login_password', with: 'password'
    click_button 'SIGN IN'

    #test if a student can see an invitation

    expect(page).to have_content "User: student2065"
    expect(page).to have_content "TestTeam"

    click_link "TestTeam"
    expect(page).to have_content "Signup sheet"
    expect(page).to have_content "Your team"

    click_link "Assignments"

    click_link "TestTeam"

    expect(page).to have_content "Your team"

    click_link "Your team"
    expect(page).to have_content "Received Invitations"
    expect(page).to have_content "student2064"


    #test if a student can accept an invitation
    click_link "Accept"
    expect(page).to have_content "Team Information"
    expect(page).to have_content "Team members"
    expect(page).to have_content "Edit name "
    expect(page).to have_content "student2064"
    expect(page).to have_content "student2065"
    expect(page).to have_content "Leave team"




    end












  end

end

#case2 team leader can invite a student to join team, and a student can decline the invitation

describe "team functionality testing case 2", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
  end

  it "case2" do

    in_browser(:one) do

      #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



      #expect(page).to have_content "Welcome!"
      #expect(page).to have_content "Assignments"
      #click_link "Assignments"


      expect(page).to have_content "User: student2064"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      #test if the topic can be seen and chosen by a student

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      #test after selecting a topic, a team formed
      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Team Name"
      expect(page).to have_content "student2064"


      #test if a team leader can invite another student



      page.fill_in 'user_name', :with => 'student2065'

      click_button('Invite')

      expect(page).to have_content "Sent invitations"
      expect(page).to have_content "student2065"





      #Capybara.reset_sessions!


      #visit root_path
      #expect(page).to have_content "User Name"
    end



    in_browser(:two) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2065')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2065'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2065"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Received Invitations"
      expect(page).to have_content "student2064"


      #test if a student can decline an invitation
      click_link "Decline"
      expect(page).to have_no_content "Received Invitations"





    end












  end
  end


#case3 team member can invite another student to join team, and a student can accept the invitation
describe "team functionality testing case 3", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
  end



  it "case3" do

    in_browser(:one) do

      #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



      #expect(page).to have_content "Welcome!"
      #expect(page).to have_content "Assignments"
      #click_link "Assignments"


      expect(page).to have_content "User: student2064"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      #test if the topic can be seen and chosen by a student

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      #test after selecting a topic, a team formed
      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Team Name"
      expect(page).to have_content "student2064"


      #test if a team leader can invite another student



      page.fill_in 'user_name', :with => 'student2065'

      click_button('Invite')

      expect(page).to have_content "Sent invitations"
      expect(page).to have_content "student2065"





      #Capybara.reset_sessions!


      #visit root_path
      #expect(page).to have_content "User Name"
    end



    in_browser(:two) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2065')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2065'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2065"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Received Invitations"
      expect(page).to have_content "student2064"


      #test if a student can accept an invitation
      click_link "Accept"
      expect(page).to have_content "Team Information"
      expect(page).to have_content "Team members"
      expect(page).to have_content "Edit name "
      expect(page).to have_content "student2064"
      expect(page).to have_content "student2065"
      expect(page).to have_content "Leave team"

      #invite another student
      page.fill_in 'user_name', :with => 'student2066'

      click_button('Invite')

      expect(page).to have_content "Sent invitations"
      expect(page).to have_content "student2066"






    end

    in_browser(:three) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2066')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2066'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2066"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Received Invitations"
      expect(page).to have_content "student2065"


      #test if a student can accept an invitation
      click_link "Accept"
      expect(page).to have_content "Team Information"
      expect(page).to have_content "Team members"
      expect(page).to have_content "Edit name "
      expect(page).to have_content "student2064"
      expect(page).to have_content "student2065"
      expect(page).to have_content "student2066"
      expect(page).to have_content "Leave team"






    end













  end
end


#case4 team member can leave team
describe "team functionality testing case 4", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
  end





  it "case4" do

    in_browser(:one) do

      #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



      #expect(page).to have_content "Welcome!"
      #expect(page).to have_content "Assignments"
      #click_link "Assignments"


      expect(page).to have_content "User: student2064"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      #test if the topic can be seen and chosen by a student

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      #test after selecting a topic, a team formed
      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Team Name"
      expect(page).to have_content "student2064"
      page.fill_in 'user_name', :with => 'student2065'

      click_button('Invite')

      expect(page).to have_content "Sent invitations"
      expect(page).to have_content "student2065"





      #Capybara.reset_sessions!


      #visit root_path
      #expect(page).to have_content "User Name"
    end



    in_browser(:two) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2065')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2065'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2065"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Received Invitations"
      expect(page).to have_content "student2064"


      #test if a student can accept an invitation
      click_link "Accept"
      expect(page).to have_content "Team Information"
      expect(page).to have_content "Team members"
      expect(page).to have_content "Edit name "
      expect(page).to have_content "student2064"
      expect(page).to have_content "student2065"
      expect(page).to have_content "Leave team"

      click_link "Leave team"
      expect(page).to have_content "You no longer have a team! "

    end

  end
  end

  #case5 team leader can leave team

describe "team functionality testing case 5", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
  end


  it "case5" do

    in_browser(:one) do

      #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



      #expect(page).to have_content "Welcome!"
      #expect(page).to have_content "Assignments"
      #click_link "Assignments"


      expect(page).to have_content "User: student2064"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      #test if the topic can be seen and chosen by a student

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      #test after selecting a topic, a team formed
      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Team Name"
      expect(page).to have_content "student2064"
      page.fill_in 'user_name', :with => 'student2065'

      click_button('Invite')

      expect(page).to have_content "Sent invitations"
      expect(page).to have_content "student2065"





      #Capybara.reset_sessions!


      #visit root_path
      #expect(page).to have_content "User Name"
    end



    in_browser(:two) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2065')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2065'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2065"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Received Invitations"
      expect(page).to have_content "student2064"


      #test if a student can accept an invitation
      click_link "Accept"
      expect(page).to have_content "Team Information"
      expect(page).to have_content "Team members"
      expect(page).to have_content "Edit name "
      expect(page).to have_content "student2064"
      expect(page).to have_content "student2065"
      expect(page).to have_content "Leave team"


    end

    in_browser(:one) do

      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "student2064"
      expect(page).to have_content "student2065"

      click_link "Leave team"
      expect(page).to have_content "You no longer have a team! "

    end

  end

end


#case 6 2 student selet the same topic should be in different teams
describe "team functionality testing case 6", type: :feature do
  before(:each) do
    create(:assignment, name: "TestTeam", directory_path: 'test_team')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
    #create(:topic)
    create(:topic, topic_name: "work1")
  end



  it "case6" do

    in_browser(:one) do

      #test log in as a student

      user = User.find_by_name('student2064')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'



      #expect(page).to have_content "Welcome!"
      #expect(page).to have_content "Assignments"
      #click_link "Assignments"


      expect(page).to have_content "User: student2064"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"

      #test if the topic can be seen and chosen by a student

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      #test after selecting a topic, a team formed
      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Your team"
      expect(page).to have_content "Team Name"
      expect(page).to have_content "student2064"



    end



    in_browser(:two) do



      #click_link('Home')
      #click_link('Logout')
      visit '/'
      #save_and_open_page



      #login as student2065

      user = User.find_by_name('student2065')
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: 'student2065'
      fill_in 'login_password', with: 'password'
      click_button 'SIGN IN'

      #test if a student can see an invitation

      expect(page).to have_content "User: student2065"
      expect(page).to have_content "TestTeam"

      click_link "TestTeam"
      expect(page).to have_content "Signup sheet"
      expect(page).to have_content "Your team"



      click_link "Assignments"

      click_link "TestTeam"

      expect(page).to have_content "Your team"

      click_link "Signup sheet"
      expect(page).to have_content "work1"
      my_link = find(:xpath, "//a[contains(@href,'sign_up_sheet/sign_up?assignment_id=#{Assignment.last.id}&id=1')]")
      my_link.click


      expect(page).to have_content "1"



    end












  end


end


