class QuestionnaireNode < Node 
  def self.table
    "questionnaires"
  end
  
  def self.get(sortvar = nil,sortorder = nil, user_id = nil,parent_id = nil)    
    query = "select nodes.* from nodes, "+self.table
    query = query+" where nodes.node_object_id = "+self.table+".id"
    query = query+" and nodes.type = '"+self.to_s+"'"
    if user_id && User.find(user_id).role_id != 6 # if not teaching assistant
      # in an TA we have to get all the questionnaires of my instructor who is registered
      # for a course
      query = query+" and "+self.table+".instructor_id = "+user_id.to_s
    elsif user_id
      query = query+" and "+self.table+".instructor_id = "+Ta.get_my_instructor(user_id).to_s
    else
      query = query+" and "+self.table+".private = 0"
    end     
    if parent_id
      query = query+ " and "+self.table+".type_id = "+parent_id.to_s
    end  
    if sortvar        
      if sortvar == 'directory_path'
        sortvar = 'name'
      end
      query = query+" order by "+self.table+"."+sortvar      
      if sortorder
        query = query+" "+sortorder
      end
    end  
    find_by_sql(query)
  end 
  
  def get_name
    Questionnaire.find(self.node_object_id).name    
  end  
    
  def get_creation_date
    Questionnaire.find(self.node_object_id).created_at
  end 
  
  # Gets the updated_at from the associated Questionnaire   
  def get_modified_date
    Questionnaire.find(self.node_object_id).updated_at
  end   
  
  def is_leaf
    true
  end  
end
