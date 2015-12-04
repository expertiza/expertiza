require 'rails_helper'
require 'spec_helper'
require_relative './helpers/login_helper'
include LogInHelper

feature 'review forms' do
	before(:each) do 
		log_in('student4346', 'password')
		click_link "Ethical analysis"
		click_link "Others' work"
	end

	feature 'bring up review forms' do
		scenario 'I dont care which topic' do	
			check("i_dont_care")
			click_button("Request a new submission to review")
			click_link("Begin")
			expect(page).to have_text("Reviews for \"Ethical analysis\"")
		end
	end

	feature 'fill out review forms' do
		scenario 'fill out form and submit' do
			click_link("Begin")
			fill_in('responses_0_comments', :with => 'Comment 0')
			fill_in('responses_1_comments', :with => 'Comment 1')
			fill_in('responses_2_comments', :with => 'Comment 2')
			click_button("Save Review")
			expect(page).to have_text("Reviews for \"Ethical analysis\"")
		end

		scenario 'fill out form, save, reopen form, and submit' do
			click_link("Begin")
			fill_in('responses_0_comments', :with => 'Comment 0')
			fill_in('responses_1_comments', :with => 'Comment 1')
			click_button("Save Review")
			click_link("Edit")			
			fill_in('responses_2_comments', :with => 'Comment 2')
			click_button("Save Review")
			expect(page).to have_text("Reviews for \"Ethical analysis\"")
		end
	end
end
