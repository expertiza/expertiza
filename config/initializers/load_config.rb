GOOGLE_CONFIG = YAML.load_file("#{Rails.root}/config/google_auth.yml")[Rails.env]
WEBSERVICE_CONFIG = YAML.load_file("#{Rails.root}/config/webservices.yml")[Rails.env]
TEXT_METRICS_KEYWORDS = YAML.load_file("#{Rails.root}/config/text_metrics_keywords.yml")[Rails.env]
