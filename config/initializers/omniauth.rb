OmniAuth.config.logger = Rails.logger

class OmniAuth::Strategies::GitHubEnterprise < OmniAuth::Strategies::GitHub
end


# Secret client and secret key configuration for google app
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_CONFIG['client_key'], GOOGLE_CONFIG['client_secret'],
           {client_options: {ssl: {verify: false}}}
  provider OmniAuth::Strategies::GitHub, GITHUB_CONFIG['client_key'], GITHUB_CONFIG['client_secret'], {provider_ignores_state: true}
  provider OmniAuth::Strategies::GitHubEnterprise, GITHUB_CONFIG['enterprise_client_key'], GITHUB_CONFIG['enterprise_client_secret'],
           {
             
             :client_options => {
               :site => "https://github.#{GITHUB_CONFIG['enterprise_domain']}/api/v3",
               :authorize_url => "https://github.#{GITHUB_CONFIG['enterprise_domain']}/login/oauth/authorize",
               :token_url => "https://github.#{GITHUB_CONFIG['enterprise_domain']}/login/oauth/access_token",
             },
             :provider_ignores_state => true,
           }
end
