# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Expertiza::Application.initialize!

config.action_mailer.delivery_method = :smtp
ActionMailer::Base.server_settings = {   :address => "smtp.example.com",   :port => 25,   :user_name => "username",   :password => "password",   :authentication => :plain }
