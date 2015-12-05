	
require 'rails_helper'
require 'spec_helper'
include LogInHelper

feature 'bring up review forms' do
	scenario 'successfully open review forms' do
	  log_in('student4349', 'password')
	  click_link "Ethical analysis 3"
	  click_link "Others' work"
	  click_link("Begin")
		expect(page).to have_text("New Review for Ethical analysis 3")
	end
end
