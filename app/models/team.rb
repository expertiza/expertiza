class Team < ActiveRecord::Base
  has_many :teams_users
  
  def delete
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", self.id])       
       teamsuser.destroy
    end    
    self.destroy
  end
  
  def get_author_name
    return self.name
  end
end
