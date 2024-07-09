Rails.application.config.lti_settings = {
  title: 'Expertiza',
  description: 'Expertiza',
  icon: 'https://your-app-url.com/path/to/icon.png',
  launch_url: 'hhttp://152.7.177.150/enrol/lti/launch.php',
  jwks_url: 'http://152.7.177.150/enrol/lti/jwks.php',
  redirect_uri: 'https://http://152.7.177.150/auth/lti/callback',
  private_key: ENV['LTI_PRIVATE_KEY'],
  deployment_ids: ['your-deployment-id'],
  client_id: 'your-client-id'
}

LTI_CONFIG = {
  consumer_key: ENV['LTI_CONSUMER_KEY'],
  shared_secret: ENV['LTI_SHARED_SECRET']
}
