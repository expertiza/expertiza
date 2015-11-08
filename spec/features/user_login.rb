require 'rubygems'
require 'capybara'
require 'capybara/dsl'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'localhost:3000'

module MyCapybaraTest
  class User_Login
    include Capybara::DSL
    def login_admin
     	visit('/')
     	#within("#session") do
    		fill_in 'login_name', :with => 'instructor6'
    		fill_in 'login_password', :with => 'password'
  		#end
      	click_button 'SIGN IN'

      	click_button 'New public course'
    end
  end
end

t = MyCapybaraTest::User_Login.new
t.login_admin