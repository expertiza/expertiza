module ParticipantsHelper

  #separates the file into the necessary elements to create a new user
  def self.upload_users(filename, session, params, home_page)
    users = Array.new
    File.open(filename, "r") do |infile|
      while (rline = infile.gets)
        config = get_config()
        attributes = define_attributes(rline.split(config["dlm"]),config)
        users << define_user(attributes, session, params, home_page)
      end    
    end    
    return users        
  end  
  
  def self.define_attributes(line_split, config)   
    attributes = {}
    attributes["role_id"] = Role.find_by_name "Student"
    attributes["name"] = line_split[config["name"].to_i]
    attributes["fullname"] = config["fullname"]
    attributes["email"] = line_split[config["email"].to_i]
    attributes["clear_password"] = assign_password(8)
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end
  
  def self.define_user(attrs, session, params, home_page)
      user = User.find_by_name(attrs["name"])        
      if user == nil
        user = create_new_user(attrs, session)
      end        
      if (params[:course_id] != nil)
        participant = add_user_to_course(params, user)   
      elsif (params[:assignment_id] != nil)
        participant = add_user_to_assignment(params, user)
      end   
      if participant != nil
        participant.email(attrs["clear_password"], home_page)
      end   
      return user 
  end
  
  def self.create_new_user(attrs, session)
    user = User.new
    user.update_attributes attrs
    user.parent_id = (session[:user]).id
    user.save
    user 
  end
  
  def self.add_user_to_assignment(params, user)
    assignment = Assignment.find params[:assignment_id]
    if (AssignmentParticipant.find(:all,{:conditions => ['user_id=? AND parent_id=?', user.id, assignment.id]}).size == 0)
      return AssignmentParticipant.create(:parent_id => assignment.id, :user_id => user.id)
    end
  end
  
  def self.add_user_to_course(params, user)
    if (CourseParticipant.find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, params[:course_id]]}).size == 0)
      CourseParticipant.create(:user_id => user.id, :parent_id => params[:course_id])
    end
  end
 
  def self.get_config
    config = {}
    cfgdir = RAILS_ROOT + "/config/"
    File.open(cfgdir+"roster_config", "r") do |infile|
      while (line = infile.gets)      
        store_item(line,"dlm",config)          
        store_item(line,"name",config)  
        store_item(line,"fullname",config)
        store_item(line,"email",config)
      end
    end
    return config
  end
  
  def self.store_item(line, ident, config)
      line_split = line.split("=")
      if line_split[0] == ident
         newstr = line_split[1].sub!("\n","")
         if newstr != nil
           config[ident] = newstr.strip
         end
      end
  end
  
end
