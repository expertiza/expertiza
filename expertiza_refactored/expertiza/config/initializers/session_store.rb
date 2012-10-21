# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_myapp_session',
  :secret      => 'e01acdbe5684b0320b0cb7dbc25762fa38f6063aea392bc63620419f244b030b1a40f43f2d829fe86d1f9fd8ea8a7bb8c524c3aaf52de614125ec85d5897724a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
