OmniAuth.config.logger = Rails.logger

# Secret client and secret key configuration for google app
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_CONFIG['client_key'], GOOGLE_CONFIG['client_secret'],
           {client_options: {ssl: {verify: false}}}
  provider :github, GITHUB_CONFIG['client_key'], GITHUB_CONFIG['client_secret'], {provider_ignores_state: true}, callback_path: "/auth/github/callback"
end