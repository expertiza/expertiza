class Team < ActiveRecord::Base
  has_many :teams_users
  has_many :users, :through => :teams_users
  
  def delete
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", self.id])       
       teamsuser.delete
    end    
    node = TeamNode.find_by_node_object_id(self.id)
    if node
      node.destroy
    end
    self.destroy
  end
  
  def get_node_type
    "TeamNode"
  end
  
  def get_author_name
    return self.name
  end
  
  def self.generate_team_name()
    counter = 0    
    while (true)
      temp = "Team #{counter}"
      if (!Team.find_by_name(temp))
        return temp
      end
      counter=counter+1
    end      
  end
  
  def get_possible_team_members(name)
     query = "select users.* from users, participants"
     query = query + " where users.id = participants.user_id"
     query = query + " and participants.type = '"+self.get_participant_type+"'"
     query = query + " and participants.parent_id = #{self.parent_id}"
     query = query + " and users.name like '#{name}%'"
     query = query + " order by users.name"
     User.find_by_sql(query) 
 end
 
 def has_user(user)
   if TeamsUser.find_by_team_id_and_user_id(self.id, user.id) 
     return true
   else
     return false
   end
 end

 def add_member(user)
   if has_user(user)
     raise "\""+user.name+"\" is already a member of the team, \""+self.name+"\""
   end
   t_user = TeamsUser.create(:user_id => user.id, :team_id => self.id) 
   parent = TeamNode.find_by_node_object_id(self.id)
   TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
   add_participant(self.parent_id, user)  
 end  
 
 def copy_members(new_team)
   members = TeamsUser.find_all_by_team_id(self.id)
   members.each{
     | member |
     t_user = TeamsUser.create(:team_id => new_team.id, :user_id => member.user_id)
     parent = TeamNode.find_by_node_object_id(self.id)   
     TeamUserNode.create(:parent_id => parent.id, :node_object_id => t_user.id)
   }   
 end
 
 def self.create_node_object(name, parent_id)
   create(:name => name, :parent_id => parent_id)
   parent = Object.const_get(self.get_parent_model).find(parent_id)
   Object.const_get(self.get_node_type).create(:parent_id => parent.id, :node_object_id => self.id)
 end 
end
