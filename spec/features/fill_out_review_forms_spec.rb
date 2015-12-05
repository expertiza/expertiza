require 'rails_helper'
require 'spec_helper'
include LogInHelper
feature 'review forms test' do
	before(:each) do
		log_in('student4349', 'password')
		click_link "Ethical analysis 3"
		click_link "Others' work"
		click_link("Begin")
	end

	feature 'bring up review forms' do
		scenario 'successfully open review forms' do
 			expect(page).to have_text("New Review for Ethical analysis 3")
		end
	end

	feature 'fill out review forms' do
		scenario 'fill out form and submit' do
			fill_in('responses_0_comments', :with => 'Comment 0')
			select('0', :from=> 'responses_0_score')
			fill_in('responses_1_comments', :with => 'Comment 1')
			select('1', :from=> 'responses_1_score')
			fill_in('responses_2_comments', :with => 'Comment 2')
			select('2', :from=> 'responses_2_score')
			fill_in('responses_3_comments', :with => 'Comment 3')
			select('3', :from=> 'responses_3_score')
			fill_in('responses_4_comments', :with => 'Comment 4')
			select('4', :from=> 'responses_4_score')
			fill_in('responses_5_comments', :with => 'Comment 5')
			select('5', :from=> 'responses_5_score')
			click_button("Save Review")
			expect(page).to have_text("Your response was successfully saved.")
		end
	end
end
