Rails.application.config.lti_settings = {
  title: 'Expertiza',
  description: 'Expertiza',
  # icon: 'https://your-app-url.com/path/to/icon.png',
  launch_url: "#{ENV['moodle_base_url']}/enrol/lti/launch.php",
  jwks_url: "#{ENV['moodle_base_url']}/enrol/lti/jwks.php",
  redirect_uri: "#{ENV['moodle_base_url']}/auth/lti/callback",
  private_key: ENV['LTI_PRIVATE_KEY'],
  deployment_ids: ['your-deployment-id'],
  client_id: 'your-client-id'
}

LTI_CONFIG = {
  consumer_key: ENV['LTI_CONSUMER_KEY'],
  shared_secret: ENV['LTI_SHARED_SECRET']
}
