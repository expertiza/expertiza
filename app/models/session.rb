class Session < ActiveRecord::SessionStore::Session
  include PublicActivity::Common
end
