class CourseParticipant < Participant
  belongs_to :course, :class_name => 'Course', :foreign_key => 'parent_id'
  
  # Copy this participant to an assignment
  def copy(assignment_id)
    part = AssignmentParticipant.find_by_user_id_and_parent_id(self.user_id,assignment_id)    
    if part.nil?       
       newpart = AssignmentParticipant.create(:user_id => self.user_id, :parent_id => assignment_id)
       newpart.set_handle()
    end
  end 
  
  # provide import functionality for Course Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)
    if row.length != 4
       raise ArgumentError, "The record containing #{row[0]} should have 4 items, it has #{row.length}."
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end              
    course = Course.find(id)
    if course == nil
       raise ImportError, "The course with id \""+id.to_s+"\" was not found."
    end
    if (find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, course.id]}).size == 0)
       create(:user_id => user.id, :parent_id => course.id)
    end   
  end 
  
  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if self.course == nil or self.course.name == nil or self.course.name.strip == ""
      return "<center>&#8212;</center>"
    end
    return self.course.name
  end  
  
  def get_parent_name
    Course.find(self.parent_id).name
  end
  
  def get_path
    Course.find(self.parent_id).get_path + self.directory_num.to_s + "/"
  end

  # provide export functionality for Assignment Participants
  def self.export(csv, parent_id, options)
    find_all_by_parent_id(parent_id).each {
        |part|
    tcsv = Array.new
      user = part.user
      if (options["personal_details"] == "true")
        tcsv.push(user.name, user.fullname, user.email)
      end
      if (options["role"] == "true")
        tcsv.push(user.role.name)
      end
      if (options["parent"] == "true")
        tcsv.push(user.parent.name)
      end
      if (options["email_options"] == "true")
        tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review)
      end
      if (options["handle"] == "true")
        tcsv.push(part.handle)
      end
      csv << tcsv
    }
  end

  def self.get_export_fields(options)
    fields = Array.new
    if (options["personal_details"] == "true")
      fields.push("name", "full name", "email")
    end
    if (options["role"] == "true")
      fields.push("role")
    end
    if (options["parent"] == "true")
      fields.push("parent")
    end
    if (options["email_options"] == "true")
      fields.push("email on submission", "email on review", "email on metareview")
    end
    if (options["handle"] == "true")
      fields.push("handle")
    end
    return fields
  end

end
