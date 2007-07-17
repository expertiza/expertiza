class Team < ActiveRecord::Base
  has_many :teams_users
end
