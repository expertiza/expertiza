require 'spec_helper'
require 'rails_helper'

include LogInHelper

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
   FactoryGirl.create(:deadline_type,name:"submission")
   FactoryGirl.create(:deadline_type,name:"review")
   FactoryGirl.create(:deadline_type,name:"resubmission")
   FactoryGirl.create(:deadline_type,name:"rereview")
   FactoryGirl.create(:deadline_type,name:"metareview")
   FactoryGirl.create(:deadline_type,name:"drop_topic")
   FactoryGirl.create(:deadline_type,name:"signup")	
   FactoryGirl.create(:deadline_type,name:"team_formation")
   # assignment=Assignment.find_by_name("final2")
   assignmentid=1
   # topic=SignUpTopic.find_by_topic_name("Statergy pattern")
   topicid=1
   end

 it 'should be choose and send invitation' do
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
 #expect(page).to have_content('student2064') 
 visit '/invitation/accept?inv_id=1&student_id=1&team_id=0'
 expect(page).to have_content('Team Name: final2_Team1')
 
end




 end
