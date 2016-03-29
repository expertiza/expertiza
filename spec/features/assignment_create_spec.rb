require 'rails_helper'
require 'selenium-webdriver'

describe "Integration tests for assignment creation" do

  describe "Assignment attributes modification", :js => true do
    pubAssignment = nil
    before(:each) do
      create(:assignment)
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

    #it "can save Submission directory" do
    #  login_as("instructor6")
    #  visit '/assignments/1/edit'
    #  fill_in 'Submission directory', with: 'www.ncsu.csc.517.edu'
    #  click_button "Save"
    #end
    it "can set assginment name" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      expect(page).to have_content "Assignment name"
      fill_in "Assignment name:", with: 'assignment for test'
      click_button "Create"
      expect(Assignment.where(name: "assignment for test")).to exist
    end

    it "can set assginment Submission directory" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in "Assignment name:", with: 'assignment for test 2'
      expect(page).to have_content "Submission directory"
      fill_in "Submission directory:", with: 'Submission directory for test'
      click_button "Create"
      expect(Assignment.find(2).directory_path).to eq 'Submission directory for test'
      #sleep 1000
    end

    it "can set assginment Description URL" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in "Assignment name:", with: 'assignment for test 3'
      expect(page).to have_content "Description URL"
      fill_in "Description URL:", with: 'Description URL for test'
      click_button "Create"
      #sleep 1000
      expect(Assignment.find(2).spec_location).to eq 'Description URL for test'
    end

    it "can set Calibrated peer-view for training" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in "Assignment name:", with: 'assignment for test 4'
      find('#assignment_form_assignment_is_calibrated').set(true)
      click_button "Create"
      #sleep 1000
      expect(Assignment.find(2).is_calibrated).to eq true
    end

    it "can Has teams and set team number" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      fill_in "Assignment name:", with: 'assignment for test 5'
      find('#team_assignment').set(true)
      expect(page).to have_content "Maximum number of members per team"
      expect(page).to have_content "Show teammate reviews"
      fill_in 'assignment_form_assignment_max_team_size', with: 4
      #  fill_in 'Maximum number of members per team:', with: 4
      find('#assignment_form_assignment_show_teammate_reviews').set(true)
      click_button "Create"
      #sleep 1000
      #expect(Assignment.find(2).is_calibrated).to eq true
      expect(Assignment.find(2).show_teammate_reviews).to eq true
    end

    it "can select course" do
      login_as("instructor6")
      visit '/assignments/new?private=0'
      #fill_in "Assignment name:", with: 'assignment for test 6'
      select('5', :from => 'assignment_form_assignment_course_id')
      click_button "Create"
      #sleep 1000
      #expect(Assignment.find(2).is_calibrated).to eq true
      #expect(Assignment.find(2).show_teammate_reviews).to eq true
    end

    it "can save the number of quiz questions" do
      login_as("instructor6")
    #visit '/assignments/new?private=0'
      visit '/assignments/new?private=0'
      fill_in "Assignment name:", with: '11'
      select('5', :from => 'assignment_form_assignment_course_id')
      find('#assignment_form_assignment_require_quiz').set(true)
    #  sleep 1000
      click_button "Create"
      visit '/assignments/2/edit'
      expect(page).to have_content "Number of Quiz questions"
      #fill_in 'assignment_form_assignment_num_quiz_questions', with: 4
      #sleep 1000
      #click_button "Save"
      #expect(Assignment.find(2).num_quiz_questions).to eq 4
    #  expect(Assignment.find(2).num_quiz_questions).to eq 4
    end

    #it "can save the number of quiz questions" do
    #   expect(Assignment.find(1).num_quiz_questions).to eq 0
    #   login_as("instructor6")
    #   visit '/assignments/1/edit'
    #   find('#assignment_form_assignment_require_quiz').set(true)
    #   click_button "Save"
    #   fill_in 'assignment_form_assignment_num_quiz_questions', with: 4
    #   click_button "Save"
    #   expect(Assignment.find(1).num_quiz_questions).to eq 4
    # end
  end
end
