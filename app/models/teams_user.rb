class TeamsUser < ActiveRecord::Base
  
  def name
    User.find(self.user_id).name
  end
end