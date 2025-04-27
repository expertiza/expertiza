Rails.application.configure do
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => "ALLOW-FROM #{ENV['moodle_base_url']}"
  }
end
