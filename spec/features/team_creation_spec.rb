require 'spec_helper'
require 'rails_helper'



# require File.join('./app/controllers/application_controller')


describe "Team Creation" do
 
  
   let(:topics){FactoryGirl.create(:topics)}

   before(:each) do
     FactoryGirl.create(:assignment)
     FactoryGirl.create(:due_date)
     FactoryGirl.create(:participants) 
     FactoryGirl.create(:participants) 
     FactoryGirl.create(:participants) 
     FactoryGirl.create(:topics)
     FactoryGirl.create(:assignmentnode)
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

 it 'one student should send an inviatation and the other student should be able to accept it' do
   student=User.find_by_name("student2064")  
   role=student.role
 
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
 
   visit '/student_task/list'
   #Assignment anme
   expect(page).to have_content('final2')
 
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
 
   click_link 'Signup sheet'
   expect(page).to have_content('Signup sheet for final2 assignment')
 
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
   expect(page).to have_content('Your topic(s)')
 
   visit '/student_task/list'

   click_link 'final2'
   click_link 'Your team'
 
   expect(page).to have_content('final2_Team1')
 
   fill_in 'user_name', with:'student2065'
   click_button 'Invite'
 
   expect(page).to have_content('student2065') 
   student=User.find_by_name("student2065")  
   role=student.role
 
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
 
   visit '/student_task/list'
   expect(page).to have_content('final2')
 
   click_link 'final2'
   click_link 'Your team'
 
   visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
   expect(page).to have_content('Team Name: final2_Team1')
 end

 it 'one student should send an inviatation and the other student should reject it' do
   student=User.find_by_name("student2064")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   
   expect(page).to have_content('final2')
   click_link 'final2'
   
   expect(page).to have_content('Submit or Review work for final2')
   click_link 'Signup sheet'
   
   expect(page).to have_content('Signup sheet for final2 assignment')
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
   
   expect(page).to have_content('Your topic(s)')
   visit '/student_task/list'
   
   expect(page).to have_content('final2')
   click_link 'final2'
   click_link 'Your team'
   
   expect(page).to have_content('final2_Team1')
   fill_in 'user_name', with:'student2065'
   click_button 'Invite'
   
   expect(page).to have_content('student2065') 
   student=User.find_by_name("student2065")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   click_link 'Your team'
   
   visit '/invitation/decline?inv_id=1&student_id=1'
   expect(page).to have_content('You no longer have a team!')
end

it 'Student should aceept the invitation sent by the other student and both have topics' do
   student=User.find_by_name("student2064")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   click_link 'Signup sheet'
   
   expect(page).to have_content('Signup sheet for final2 assignment')
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
   #expect(page).to have_content('Your topic(s)')
   #signup for topic for user1 finish
   student=User.find_by_name("student2065")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   
   click_link 'Signup sheet'
   expect(page).to have_content('Signup sheet for final2 assignment')
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=2'
   #expect(page).to have_content('Your topic(s)')
   #signup for topic for user2 finish
   student=User.find_by_name("student2064")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   
   click_link 'Your team'
   expect(page).to have_content('final2_Team1')
   fill_in 'user_name', with:'student2065'
   
   click_button 'Invite'
   expect(page).to have_content('Waiting for reply')
   
   student=User.find_by_name("student2065")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   click_link 'final2'
   
   click_link 'Your team'
   visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
   
   expect(page).to have_content('Team Name: final2_Team1')
 end

 it 'student should reject the invitation sent by the other student and both gave topics' do
   student=User.find_by_name("student2064")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   
   click_link 'Signup sheet'
   expect(page).to have_content('Signup sheet for final2 assignment')
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
   #expect(page).to have_content('Your topic(s)')
   #signup for topic for user1 finish
   student=User.find_by_name("student2065")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   
   click_link 'Signup sheet'
   expect(page).to have_content('Signup sheet for final2 assignment')
   visit '/sign_up_sheet/sign_up?assignment_id=1&id=2'
   #expect(page).to have_content('Your topic(s)')
   #signup for topic for user2 finish
   student=User.find_by_name("student2064")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   expect(page).to have_content('final2')
   
   click_link 'final2'
   expect(page).to have_content('Submit or Review work for final2')
   
   click_link 'Your team'
   expect(page).to have_content('final2_Team1')
   
   fill_in 'user_name', with:'student2065'
   click_button 'Invite'
   
   expect(page).to have_content('Waiting for reply')
   
   student=User.find_by_name("student2065")  
   role=student.role
   
   ApplicationController.any_instance.stub(:current_user).and_return(student)
   ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
   ApplicationController.any_instance.stub(:current_role).and_return(role)
   
   visit '/student_task/list'
   click_link 'final2'
   
   click_link 'Your team'
   
   visit '/invitation/decline?inv_id=1&student_id=1'
   expect(page).to have_content('Team Name: final2_Team2')
 end

it 'Student should accept other students invitation and both does not have a topic' do
  student=User.find_by_name("student2066")  
  role=student.role
  
  ApplicationController.any_instance.stub(:current_user).and_return(student)
  ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
  ApplicationController.any_instance.stub(:current_role).and_return(role)
  
  visit '/student_task/list'
  expect(page).to have_content('final2')
  click_link 'final2'
    
  expect(page).to have_content('Submit or Review work for final2')
  click_link 'Signup sheet'
  
  expect(page).to have_content('Signup sheet for final2 assignment')
  visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
  expect(page).to have_content('Your topic(s)')
     
  student=User.find_by_name("student2064")  
  role=student.role
  
  ApplicationController.any_instance.stub(:current_user).and_return(student)
  ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
  ApplicationController.any_instance.stub(:current_role).and_return(role)
  
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
   #send invition to student5710 without topic
  student=User.find_by_name("student2065")  
  role=student.role
  
  ApplicationController.any_instance.stub(:current_user).and_return(student)
  ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
  ApplicationController.any_instance.stub(:current_role).and_return(role)
  
  visit '/student_task/list'
  expect(page).to have_content('final2')
  
  click_link 'final2'
  visit '/student_teams/view?student_id=2'
  visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
  expect(page).to have_content('team1')
end

it "Student should reject the other students invitaton and both dont have a topic" do
  student=User.find_by_name("student2066")  
  role=student.role
  
  ApplicationController.any_instance.stub(:current_user).and_return(student)
  ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
  ApplicationController.any_instance.stub(:current_role).and_return(role)
  
  visit '/student_task/list'
  
  expect(page).to have_content('final2')
 click_link 'final2'
 
 
 expect(page).to have_content('Submit or Review work for final2')
 click_link 'Signup sheet'
 expect(page).to have_content('Signup sheet for final2 assignment')
 visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
 expect(page).to have_content('Your topic(s)')
   
student=User.find_by_name("student2064")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
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
 #send invition to student5710 without topic
 student=User.find_by_name("student2065")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
 visit '/student_task/list'
 expect(page).to have_content('final2')
 click_link 'final2'
  visit '/student_teams/view?student_id=2'
  visit '/invitation/decline?inv_id=1&student_id=1'
 expect(page).to have_content('You no longer have a team!')


end 
it 'Student should accept the invitation sent by other student who has a topic' do
 student=User.find_by_name("student2065")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
 visit '/student_task/list'  
 expect(page).to have_content('final2')
 click_link 'final2'
 expect(page).to have_content('Submit or Review work for final2')
 click_link 'Signup sheet'
 expect(page).to have_content('Signup sheet for final2 assignment')
 visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
 expect(page).to have_content('Your topic(s)')
 
 #choose a topic for student5710
student=User.find_by_name("student2064")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
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
 #send invition to student5710 without topic
 student=User.find_by_name("student2065")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
 visit '/student_task/list'
 expect(page).to have_content('final2')
 click_link 'final2'
 click_link 'Your team'
 visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
 expect(page).to have_content('team1')
end

it "Student should reject the inviattion sent by the other student who haa a topic" do
student=User.find_by_name("student2065")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
 visit '/student_task/list'  
 expect(page).to have_content('final2')
 click_link 'final2'
 expect(page).to have_content('Submit or Review work for final2')
 click_link 'Signup sheet'
 expect(page).to have_content('Signup sheet for final2 assignment')
 visit '/sign_up_sheet/sign_up?assignment_id=1&id=1'
 expect(page).to have_content('Your topic(s)')
 
 #choose a topic for student5710
student=User.find_by_name("student2064")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
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
 #send invition to student5710 without topic
 student=User.find_by_name("student2065")  
 role=student.role
 ApplicationController.any_instance.stub(:current_user).and_return(student)
 ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
 ApplicationController.any_instance.stub(:current_role).and_return(role)
 visit '/student_task/list'
 expect(page).to have_content('final2')
 click_link 'final2'
 click_link 'Your team'
  visit '/invitation/decline?inv_id=1&student_id=1'
 expect(page).to have_content('Team Name: final2_Team1')
end

end
