# Errbit is an online tool that provides robust exception tracking in your Rails
# applications. Errbit enables for easy categorization, storing and searching
# of exceptions so that when errors occur, your team can quickly determine the
# root cause.
Airbrake.configure do |config|

  # You must set both project_id & project_key. To find your project_id and
  # project_key navigate to your project's General Settings and copy the values
  # from the right sidebar.
  config.host = 'https://errbit-expertiza2019.herokuapp.com'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = '64ed97f0c8e628acefb3a7f63308a11c'
  config.environment = Rails.env

  # Setting this option allows Airbrake to filter exceptions occurring in
  # unwanted environments such as :test. By default, it is equal to an empty
  # Array, which means Airbrake Ruby sends exceptions occurring in all
  # environments.
  # NOTE: This option *does not* work if you don't set the 'environment' option.
   config.ignore_environments = %w(test)
end



