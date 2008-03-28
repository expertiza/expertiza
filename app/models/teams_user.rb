class TeamsUser < ActiveRecord::Base
  
  def get_field(field)
    user = User.find(self.user_id)
    return user[field.to_sym]
  end
end