require 'rails_helper'
RSpec.feature "logging in"  do 
	scenario "allow instructor to log in" do	
		visit 'content_pages#view'
		fill_in 'login_name', with: "instructor6"
		fill_in 'login_password', with: "password"

		click_on 'SIGN IN'

		expect(page).to have_content 'Manage content'
	end

end