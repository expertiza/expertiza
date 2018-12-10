OmniAuth.config.logger = Rails.logger
GITHUB_CONFIG = {}
GITHUB_CONFIG['client_key'] = '9bc295b263c0386b247a'
GITHUB_CONFIG['client_secret'] = 'db117b422bfaa2a4c4038921db2634ce56ceeb09

# Secret client and secret key configuration for google app
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_CONFIG['client_key'], GOOGLE_CONFIG['client_secret'],
           {client_options: {ssl: {verify: false}}}
  provider :github, GITHUB_CONFIG['client_key'], GITHUB_CONFIG['client_secret'], {provider_ignores_state: true}
end