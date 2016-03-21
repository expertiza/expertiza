require 'rails_helper'


describe "Integration tests for assignment interface" do

  before(:each) do
    @assignment = create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type,name:"submission")
    create(:deadline_type,name:"review")
    create(:deadline_type,name:"resubmission")
    create(:deadline_type,name:"rereview")
    create(:deadline_type,name:"metareview")
    create(:deadline_type,name:"drop_topic")
    create(:deadline_type,name:"signup")
    create(:deadline_type,name:"team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:due_date)
    create(:due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100*24*60*60))
  end

  describe "Create assignments" do
    pubAssignment = nil; privAssignment = nil

    it "is able to create a public assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
      select('5', :from => 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      click_button 'Create'
      pubAssignment = Assignment.where(name: 'public assignment for test')
      expect(pubAssignment).to exist
    end

    it "is able to create a private assignment" do
      login_as("instructor6")
      visit '/assignments/new?private=1'
      fill_in 'assignment_form_assignment_name', with: 'private assignment for test'
      select('5', :from => 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      click_button 'Create'
      privAssignment = Assignment.where(name: 'private assignment for test')
      expect(privAssignment).to exist
    end
  end

  describe "Edit assignments" do
    it "is able to edit assignment" do
      login_as("instructor6")
      visit '/assignments/1/edit'
      expect(page).to have_content("Editing Assignment:")
    end
  end

  describe "Edit rubric" do
    it "is able to edit assignment" do
      login_as("instructor6")
      visit '/assignments/1/edit#tabs-3'

      expect(page).to have_content("Review rubric varies by round?")
      expect
    end
  end
end