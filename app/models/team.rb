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
            
            Participant.create(:assignment_id => assignment.id, :user_id => user.id, :permission_granted => true)
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
end
