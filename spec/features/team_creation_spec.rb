require 'rails_helper'

describe "Team Creation" do
   
  before(:each) do
    FactoryGirl.create(:assignment)
    FactoryGirl.create(:due_date)
    FactoryGirl.create(:participants) 
    FactoryGirl.create(:participants) 
    FactoryGirl.create(:participants) 
    FactoryGirl.create(:assignment_node)
    FactoryGirl.create(:topics)
    FactoryGirl.create(:topics,topic_name:"command pattern")
    FactoryGirl.create(:deadline_type,name:"submission")
    FactoryGirl.create(:deadline_type,name:"review")
    FactoryGirl.create(:deadline_type,name:"resubmission")
    FactoryGirl.create(:deadline_type,name:"rereview")
    FactoryGirl.create(:deadline_type,name:"metareview")
    FactoryGirl.create(:deadline_type,name:"drop_topic")
    FactoryGirl.create(:deadline_type,name:"signup")	
    FactoryGirl.create(:deadline_type,name:"team_formation")
  end

  describe 'one student who signup for a topic should send an inviatation to the other student who has no topic' do
       
     before(:each) do
       login_as("student2064")
       visit '/student_task/list'
       #Assignment name
       expect(page).to have_content('final2')
     
       click_link 'final2'
       expect(page).to have_content('Submit or Review work for final2')
     
       click_link 'Signup sheet'
       expect(page).to have_content('Signup sheet for final2 assignment')
     
       #click Signup check button
       visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
       expect(page).to have_content('Your topic(s):
Hello world! ')

       visit '/student_task/list'
       click_link 'final2'
       click_link 'Your team'
       expect(page).to have_content('final2_Team1')
     
       fill_in 'user_name', with:'student2065'
       click_button 'Invite'
       expect(page).to have_content('student2065') 

       login_as("student2065")      
       visit '/student_task/list'
       expect(page).to have_content('final2')
     
       click_link 'final2'
       click_link 'Your team'
   end

   it 'is able to accept the invitation and form team'  do
     visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
     expect(page).to have_content('Team Name: final2_Team1')
   end

    it 'is not able to form team on rejecting' do
     visit '/invitation/decline?inv_id=1&student_id=1'
     expect(page).to have_content('You no longer have a team!')
    end

  end

  describe 'one student who has a topic sends an invitation to other student who also has a topic' do
    
    before(:each) do
     login_as("student2064")  
     visit '/student_task/list'
     expect(page).to have_content('final2')
     
     click_link 'final2'
     expect(page).to have_content('Submit or Review work for final2')

     click_link 'Signup sheet'
     expect(page).to have_content('Signup sheet for final2 assignment')

     visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
     #expect(page).to have_content('Your topic(s)')
     #signup for topic for user1 finish
     login_as("student2065")      
     visit '/student_task/list'
     expect(page).to have_content('final2')
     
     click_link 'final2'
     expect(page).to have_content('Submit or Review work for final2')
     
     click_link 'Signup sheet'
     expect(page).to have_content('Signup sheet for final2 assignment')

     visit '/sign_up_sheet/sign_up?assignment_id=1&id=2'
     #expect(page).to have_content('Your topic(s)')
     #signup for topic for user2 finish
     login_as("student2064")  
     visit '/student_task/list'
     expect(page).to have_content('final2')
     
     click_link 'final2'
     expect(page).to have_content('Submit or Review work for final2')
     
     click_link 'Your team' 
     expect(page).to have_content('final2_Team1')

     fill_in 'user_name', with:'student2065'
     click_button 'Invite'
     expect(page).to have_content('Waiting for reply')
     
     login_as("student2065")         
     visit '/student_task/list'
     click_link 'final2'
     click_link 'Your team'
   end

    it 'Student should aceept the invitation sent by the other student and both have topics' do
       visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
       expect(page).to have_content('Team Name: final2_Team1')
     end

     it 'student should reject the invitation sent by the other student and both gave topics' do
       visit '/invitation/decline?inv_id=1&student_id=1'
       expect(page).to have_content('Team Name: final2_Team2')
     end
  end

  describe 'one student should send an invitation to other student and both does not have topics' do

    before(:each) do
      login_as("student2066")  
      visit '/student_task/list'
      expect(page).to have_content('final2')

      click_link 'final2'
      expect(page).to have_content('Submit or Review work for final2')

      click_link 'Signup sheet'
      expect(page).to have_content('Signup sheet for final2 assignment')

      visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
      expect(page).to have_content('Your topic(s)')
         
      login_as("student2064")  
      visit '/student_task/list'
      expect(page).to have_content('final2')
      
      click_link 'final2'
      expect(page).to have_content('Your team')
      
      click_link 'Your team'
      expect(page).to have_content('View team for final2')
      
      fill_in 'team_name', with:'team1'
      click_button 'Name team'
      expect(page).to have_content('team1')
       
      fill_in 'user_name', with:'student2065'
      click_button 'Invite'
      expect(page).to have_content('Waiting for reply')

      login_as("student2065")  
      visit '/student_task/list'
      expect(page).to have_content('final2')
      
      click_link 'final2'
      visit '/student_teams/view?student_id=2'
    end

    it 'Student should accept other students invitation and both does not have a topic' do
      visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
      expect(page).to have_content('team1')
    end

    it "Student should reject the other students invitaton and both dont have a topic" do
     visit '/invitation/decline?inv_id=1&student_id=1'
     expect(page).to have_content('You no longer have a team!')
     end
    end

  describe 'one student should send an invitation to other student who has a topic signed up for' do

    before(:each) do
     login_as("student2065")  
     visit '/student_task/list'  
     expect(page).to have_content('final2')

     click_link 'final2'
     expect(page).to have_content('Submit or Review work for final2')

     click_link 'Signup sheet'
     expect(page).to have_content('Signup sheet for final2 assignment')

     visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
     expect(page).to have_content('Your topic(s)')
     
     #choose a topic for student5710
     login_as("student2064")  
     visit '/student_task/list'  
     expect(page).to have_content('final2')

     click_link 'final2'
     click_link 'Your team'
     expect(page).to have_content('View team for final2')

     fill_in 'team_name', with:'team1'
     click_button 'Name team'
     expect(page).to have_content('team1')

     fill_in 'user_name', with:'student2065'
     click_button 'Invite'
     expect(page).to have_content('Waiting for reply')

     login_as("student2065")  
     visit '/student_task/list'
     expect(page).to have_content('final2')
     click_link 'final2'
     click_link 'Your team'
    end

   it 'Student should accept the invitation sent by other student who has a topic' do
    visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
    expect(page).to have_content('team1')
   end

   it "Student should reject the inviattion sent by the other student who haa a topic" do

    visit '/invitation/decline?inv_id=1&student_id=1'
    expect(page).to have_content('Team Name: final2_Team1')
   end
  end
end