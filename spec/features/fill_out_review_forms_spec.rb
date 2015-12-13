require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

feature 'fill out review forms' do
	scenario 'fill out form and save' do
		log_in('student1', 'password')
		click_link "Assignment1"
		click_link "Others' work"
	  	check('i_dont_care')
	  	click_button("Request a new submission to review")
		click_link("Begin")
		fill_in('responses_0_comments', :with => 'Comment 0')
		fill_in('responses_1_comments', :with => 'Comment 1')
		fill_in('responses_2_comments', :with => 'Comment 2')
		click_button("Save Review")
		expect(page).to have_text("Your response was successfully saved.")
	end

	scenario 'fill out form, save, edit, and save again' do
		log_in('student2', 'password')
		click_link "Assignment1"
		click_link "Others' work"
	  	check('i_dont_care')
	  	click_button("Request a new submission to review")
		click_link("Begin")
		fill_in('responses_0_comments', :with => 'Comment 0')
		click_button("Save Review")
		click_link("Edit")
		fill_in('responses_1_comments', :with => 'Comment 1')
		fill_in('responses_2_comments', :with => 'Comment 2')
		click_button("Save Review")
		expect(page).to have_text("Reviews for \"Assignment1\"")
	end
end
