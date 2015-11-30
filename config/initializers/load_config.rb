GOOGLE_CONFIG = YAML.load_file("#{Rails.root }/config/google_auth.yml")[Rails.env]
GITHUB_CONFIG = YAML.load_file("#{Rails.root }/config/github_auth.yml")[Rails.env]
