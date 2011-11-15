<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
module TeamHelper

  #separates the file into the necessary elements to create a new user
  def self.upload_teams(file, assignment_id, options,logger) 
    unknown = Array.new
    while (rline = file.gets)        
        split_line = rline.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)       
        if options[:has_column_names] == "true"
          name = split_line[0]
          pos = 1
        else
          name = generate_team_name()
          pos = 0
        end 
        teams = Team.find(:all, :conditions => ["name =? and assignment_id =?",name,assignment_id]) 
        currTeam = teams.first 
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
        if teams.length == 0 || currTeam == nil
          currTeam = Team.new
          currTeam.name = name
          currTeam.assignment_id = assignment_id
          currTeam.save
        end
              
       logger.info "#{split_line.length}"
       logger.info "#{split_line}"
       while(pos < split_line.length) 
          user = User.find_by_name(split_line[pos].strip)
          if user && !(options[:handle_dups] == "ignore" && teams.length > 0)            
            teamusers = TeamsUser.find(:all, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])
            currUser = teamusers.first
            if teamusers.length == 0 || currUser == nil
              currUser = TeamsUser.new
              currUser.team_id = currTeam.id
              currUser.user_id = user.id
              currUser.save   
              
              Participant.create(:assignment_id => assignment_id, :user_id => user.id, :permission_granted => true)
            end                      
          else
            unknown << split_line[pos]
          end
          pos = pos+1
        end
      end         
       
    return unknown
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
<<<<<<< HEAD
=======
=======
module TeamHelper

  #separates the file into the necessary elements to create a new user
  def self.upload_teams(file, assignment_id, options,logger) 
    unknown = Array.new
    while (rline = file.gets)        
        split_line = rline.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)       
        if options[:has_column_names] == "true"
          name = split_line[0]
          pos = 1
        else
          name = generate_team_name()
          pos = 0
        end 
        teams = Team.find(:all, :conditions => ["name =? and assignment_id =?",name,assignment_id]) 
        currTeam = teams.first 
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
        if teams.length == 0 || currTeam == nil
          currTeam = Team.new
          currTeam.name = name
          currTeam.assignment_id = assignment_id
          currTeam.save
        end
              
       logger.info "#{split_line.length}"
       logger.info "#{split_line}"
       while(pos < split_line.length) 
          user = User.find_by_name(split_line[pos].strip)
          if user && !(options[:handle_dups] == "ignore" && teams.length > 0)            
            teamusers = TeamsUser.find(:all, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])
            currUser = teamusers.first
            if teamusers.length == 0 || currUser == nil
              currUser = TeamsUser.new
              currUser.team_id = currTeam.id
              currUser.user_id = user.id
              currUser.save   
              
              Participant.create(:assignment_id => assignment_id, :user_id => user.id, :permission_granted => true)
            end                      
          else
            unknown << split_line[pos]
          end
          pos = pos+1
        end
      end         
       
    return unknown
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
module TeamHelper

  #separates the file into the necessary elements to create a new user
  def self.upload_teams(file, assignment_id, options,logger) 
    unknown = Array.new
    while (rline = file.gets)        
        split_line = rline.split(/,(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))/)       
        if options[:has_column_names] == "true"
          name = split_line[0]
          pos = 1
        else
          name = generate_team_name()
          pos = 0
        end 
        teams = Team.find(:all, :conditions => ["name =? and assignment_id =?",name,assignment_id]) 
        currTeam = teams.first 
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
        if teams.length == 0 || currTeam == nil
          currTeam = Team.new
          currTeam.name = name
          currTeam.assignment_id = assignment_id
          currTeam.save
        end
              
       logger.info "#{split_line.length}"
       logger.info "#{split_line}"
       while(pos < split_line.length) 
          user = User.find_by_name(split_line[pos].strip)
          if user && !(options[:handle_dups] == "ignore" && teams.length > 0)            
            teamusers = TeamsUser.find(:all, :conditions => ["team_id =? and user_id =?", currTeam.id,user.id])
            currUser = teamusers.first
            if teamusers.length == 0 || currUser == nil
              currUser = TeamsUser.new
              currUser.team_id = currTeam.id
              currUser.user_id = user.id
              currUser.save   
              
              Participant.create(:assignment_id => assignment_id, :user_id => user.id, :permission_granted => true)
            end                      
          else
            unknown << split_line[pos]
          end
          pos = pos+1
        end
      end         
       
    return unknown
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
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
