OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '1025716012590-2nlv84m8uo3pled9bide8442r2020gc3.apps.googleusercontent.com', 'kWjKq314ywRKAF5s5A0F8Wxh',
           {client_options: {ssl: {verify: false}}}
end