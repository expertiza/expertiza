GOOGLE_CONFIG = YAML.load_file("#{Rails.root}/config/google_auth.yml")[Rails.env]
WEBSERVICE_CONFIG = YAML.load_file("#{Rails.root}/config/webservices.yml")[Rails.env]
PLAGIARISM_CHECKER_CONFIG = YAML.load_file("#{Rails.root}/config/plagiarism_checker.yml")[Rails.env]
REVIEW_METRIC_CONFIG = YAML.load_file("#{Rails.root}/config/review_metrics.yml")[Rails.env]
API_ANALYSIS_VALUES = YAML.load_file("#{Rails.root}/config/api_analysis_vals.yml")