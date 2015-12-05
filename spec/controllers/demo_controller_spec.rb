require 'rails_helper'

describe DemoController do
	describe "create action" do
		it "should be able to create a demo instructor" do
			assert_difference('User.count',1) do
      			post :create, :user => { :name => "jdoe",
      						   :fullname=>"andrew",
      						   :email=>"ravillaroshini@gmail.com",
                               :password => "secret", 
                               :password_confirmation => "secret" }
    		end
    	end
    	it "should check the credentials with existing users and doesnot save with same user id" do
			  assert_difference('User.count') do
      			post :create, :user => { :name => "adam",
      						   :fullname=>"smith",
      						   :email=>"adamsmith@gmail.com",
                    :password => "secret", 
                    :password_confirmation => "secret" }
        end
        assert_difference('User.count') do
            post :create, :user => { :name => "adam",
                     :fullname=>"smith",
                     :email=>"adamsmith@gmail.com",
                    :password => "secret", 
                    :password_confirmation => "secret" }
        end
        assert_difference('User.count',0) do
            post :create, :user => { :name => "adam",
                     :fullname=>"smith",
                     :email=>"adamsmith@gmail.com",
                    :password => "secret", 
                    :password_confirmation => "secret" }
        end
		end
	end
end
