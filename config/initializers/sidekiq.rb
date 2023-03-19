# Resolve "TypeError (can't cast Rack::Session::SessionId to string)" in sidekiq
# https://github.com/mperham/sidekiq/issues/4421
require 'sidekiq/web'
Sidekiq::Web.set :sessions, false