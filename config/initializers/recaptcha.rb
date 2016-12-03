# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.site_key  = '6LdQig0UAAAAAHx0HjYG_QHY9hsGQMiA0if1UDnd'
  config.secret_key = '6LdQig0UAAAAAGFKGgQAf5YDHyacRxFUC8whtwCo'
  # Uncomment the following line if you are using a proxy server:
   config.proxy = 'http://google.com/recaptcha/api/verify'


end