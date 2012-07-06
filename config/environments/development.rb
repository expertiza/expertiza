# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Set to false if you don't care if the mailer can't send, else, set to true if you do care
config.action_mailer.raise_delivery_errors = false

# This was added so one could test whether an email was being sent.
# Note, the template below assumes a gmail account, however, it can be adapted
# for other smtp server information as well.
#ActionMailer::Base.smtp_settings = {
#   :address => "smtp.gmail.com",
#   :port => 587,
#   :domain => 'gmail.com',
#   :authentication => :plain,
#   :user_name=>'username',
#   :password=>'password',
#   :enable_starttls_auto => true
#}

config.log_level = :info