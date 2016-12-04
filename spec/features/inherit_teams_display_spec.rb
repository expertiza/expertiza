require 'rails_helper'

describe 'displaying inherit teams section' do
#=begin
  it 'should display inherit teams option while creating an assignment team' do
    #create(:assignment, name:"inherit_team")
    #@inherit_n1 = Assignment.where(name:'inherit_team').first
    #create(:assignment_node, node_object_id:@inherit_n1.id)
    #create(:assignment_team,name:'inherit_team1',assignment:Assignment.find_by(name:'inherit_team'))

    @inherit1 = Assignment.where(name:'inherit_team').first
    login_as("instructor6")
    visit "/teams/list?id=#{@inherit1.id}&type=Assignment"
    #visit '/teams/list?id=2&type=Assignment'
    click_link 'Create Team'
    expect(page).to have_content('Inherit Teams From Course')
  end
  
   it 'should not display inherit teams option while creating a course team' do
    #create(:course,name:"inherit_course")
    #@inherit_n2 = Course.where(name:'inherit_course').first
    #create(:course_node,node_object_id: @inherit_n2.id)
    #create(:course_team,name:"inherit_course_team")

    login_as("instructor6")
    @inherit2=Course.where(name:'inherit_course').first
    visit "/teams/list?id=#{@inherit2.id}&type=Course"

    click_link 'Create Team'
    expect(page).to have_no_content('Inherit Teams From Course')
  end
#=end
   it 'should not display inherit teams option while creating team for an assignment without a course' do
   # assignment = create(:assignment, name:"inherit_not_display_team")
   # @inherit_n3 = Assignment.where(name:'inherit_not_display_team').first
   # create(:assignment_node,node_object_id:@inherit_n3.id)
   # assignment.update_attributes(course_id: nil)

     @inherit1 = Assignment.where(name:'inherit_not_display_team').first
     login_as("instructor6")
     visit "/teams/list?id=#{@inherit1.id}&type=Assignment"
    click_link 'Create Team'
    expect(page).to have_no_content('Inherit Teams From Course')
  end
  
end

