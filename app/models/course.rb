class Course < ActiveRecord::Base
  has_many :ta_mappings
  validates_presence_of :name
  has_many :assignments
  belongs_to :instructor, :class_name => 'User', :foreign_key => 'instructor_id'
  has_many :participants, :class_name => 'CourseParticipant', :foreign_key => 'parent_id'
  
  # Return any predefined teams associated with this course
  # Author: ajbudlon
  # Date: 7/21/2008
  def get_teams
    return CourseTeam.find_all_by_parent_id(self.id)        
  end

  #Returns this object's submission directory
  def get_path
    if self.instructor_id == nil
      raise "Path can not be created. The course must be associated with an instructor."
    end    
    return RAILS_ROOT + "/pg_data/" +  FileHelper.clean_path(User.find(self.instructor_id).name)+ "/" + FileHelper.clean_path(self.directory_path) + "/"      
  end
  
  def get_participants
    CourseParticipant.find_all_by_parent_id(self.id)
  end

  def get_participant (user_id)
    CourseParticipant.find_all_by_parent_id_and_user_id(self.id, user_id)
  end
  
  def add_participant(user_name)
    user = User.find_by_name(user_name)
    if (user == nil) 
      raise "No user account exists with the name "+user_name+". Please <a href='"+url_for(:controller=>'users',:action=>'new')+"'>create</a> the user first."      
    end
    participant = CourseParticipant.find_by_parent_id_and_user_id(self.id, user.id)
    unless participant # If there is already a participant, it has already been added. done. Otherwise, create it
      CourseParticipant.create(:parent_id => self.id, :user_id => user.id, :permission_granted => user.master_permission_granted)
    end    
  end
  
  def copy_participants(assignment_id)    
    participants = AssignmentParticipant.find_all_by_parent_id(assignment_id)
    errors = Array.new
    error_msg = String.new
    participants.each{
      |participant|
      user = User.find(participant.user_id)
      
      begin
        self.add_participant(user.name)
      rescue
        errors << $!
      end
    }    
    if errors.length > 0
      errors.each {
        | error |
        if error
          error_msg = error_msg+"<BR/>"+error
        end
      }
      raise error_msg
    end                   
  end
  
   def create_node()
      folder = TreeFolder.find_by_name('Courses')
      parent = FolderNode.find_by_node_object_id(folder.id)
      node = CourseNode.create(:node_object_id => self.id)
      if parent != nil
        node.parent_id = parent.id       
      end
      node.save   
   end  
end
