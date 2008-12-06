class Team < ActiveRecord::Base
  has_many :teams_users
  
  def delete
    for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", self.id])       
       teamsuser.delete
    end    
    node = TeamNode.find_by_node_object_id(self.id)
    node.destroy    
    self.destroy
  end
  
  def get_node_type
    "TeamNode"
  end
  
  def get_author_name
    return self.name
  end
  
  def self.import(row,session,id,options)
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment == nil
      raise ImportError, "The assignment with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    
    if options[:has_column_names] == "true"
        name = row[0].to_s.strip
        index = 1
    else
        name = generate_team_name()
        index = 0
    end 
    
    currTeam = Team.find(:first, :conditions => ["name =? and assignment_id =?",name,assignment.id])
    
    if options[:handle_dups] == "ignore" && currTeam != nil
      return
    end
    
    if currTeam != nil && options[:handle_dups] == "rename"
       name = generate_team_name()
       currTeam = nil
    end
    if options[:handle_dups] == "replace" && teams.first != nil        
       for teamsuser in TeamsUser.find(:all, :conditions => ["team_id =?", currTeam.id])
           teamsuser.destroy
       end    
       currTeam.destroy
       currTeam = nil
    end     
    
    if currTeam == nil
       currTeam = Team.new
       currTeam.name = name
       currTeam.assignment_id = assignment.id
       currTeam.save
    end
      
    while(index < row.length) 
        user = User.find_by_name(row[index].to_s.strip)
        if user == nil
          raise ImportError, "The user \""+row[index].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"                           
        elsif currTeam != nil         
          currUser = TeamsUser.find(:first, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])          
          if currUser == nil
            currUser = TeamsUser.new
            currUser.team_id = currTeam.id
            currUser.user_id = user.id
            currUser.save   
            
            AssignmentParticipant.create(:assignment_id => assignment.id, :user_id => user.id, :permission_granted => true)
          end                      
        end
        index = index+1      
    end                
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
  
  def get_team_users
   User.find_by_sql("select * from users where id in (select user_id from teams_users where team_id = #{self.id}) order by users.fullname")   
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
