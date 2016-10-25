GOOGLE_CONFIG = YAML.load_file("#{Rails.root}/config/google_auth.yml")[Rails.env]
WEBSERVICE_CONFIG = YAML.load_file("#{Rails.root}/config/webservices.yml")[Rails.env]
