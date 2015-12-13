	
require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

feature 'bring up review forms' do
	scenario 'successfully open chosen review forms' do
	  log_in('student1', 'password')
	  click_link "Assignment1"
	  click_link "Others' work"
	  choose('topic_id_3')
	  click_button("Request a new submission to review")
	  click_link('Begin')
		expect(page).to have_text("New Review for Assignment1")
	end

       	scenario 'successfully open random review forms' do
	  log_in('student2', 'password')
	  click_link "Assignment1"
	  click_link "Others' work"
	  check('i_dont_care')
	  click_button("Request a new submission to review")
	  click_link('Begin')
		expect(page).to have_text("New Review for Assignment1")
	end
	
	scenario 'successfully open review without topic' do
	  log_in('student3', 'password')
	  click_link "Assignment2"
	  click_link "Others' work"
	  click_button("Request a new submission to review")
	  click_link('Begin')
		expect(page).to have_text("New Review for Assignment2")
	end
end
