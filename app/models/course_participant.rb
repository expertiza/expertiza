class CourseParticipant < Participant
  
  # provide import functionality for Course Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)
    if row.length != 4
       raise ArgumentError, "Not enough items" 
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end              
    course = Course.find(id)
    if assignment == nil
       raise ImportError, "The assignment with id \""+id.to_s+"\" was not found."
    end
    if (find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, course.id]}).size == 0)
       create(:user_id => user.id, :parent_id => course.id)
    end   
  end    
  
  def get_parent_name
    Course.find(self.parent_id).name
  end
  
  def get_path
    Course.find(self.parent_id).get_path + self.directory_num.to_s + "/"
  end
end
