class CourseParticipant < Participant

  belongs_to :course, :class_name => 'Course', :foreign_key => 'parent_id'

  attr_accessible :can_submit, :can_review, :user_id, :parent_id, :submitted_at, :permission_granted, :penalty_accumulated, :grade, :type, :handle, :time_stamp, :digital_signature, :duty, :can_take_quiz

  # Copy this participant to an assignment
  def copy(assignment_id)
    part = AssignmentParticipant.where(user_id: self.user_id, parent_id: assignment_id).first
    if part.nil?
      part = AssignmentParticipant.create(:user_id => self.user_id, :parent_id => assignment_id)
      part.set_handle()
      return part
    else
      return nil # return nil so we can tell a copy is not made
    end
  end

  # provide import functionality for Course Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,row_header=nil,session,id)
    raise ArgumentError, "No user id has been specified." if row.length < 1
    user = User.find_by_name(row[0])
    if user == nil
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end
    course = Course.find(id)
    if course == nil
      raise ImportError, "The course with id \""+id.to_s+"\" was not found."
    end
    if !CourseParticipant.exists?(:user_id => user.id, :parent_id => course.id)
      CourseParticipant.create(:user_id => user.id, :parent_id => course.id)
    end
  end

  def course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if self.course == nil or self.course.name == nil or self.course.name.strip == ""
      return "<center>&#8212;</center>"
    end
    return self.course.name
  end

  def path
    Course.find(self.parent_id).path + self.directory_num.to_s + "/"
  end

  # provide export functionality for Assignment Participants
  def self.export(csv, parent_id, options)
    where(parent_id: parent_id).each {
      |part|
      tcsv = Array.new
      user = part.user
      if options["personal_details"] == "true"
        tcsv.push(user.name, user.fullname, user.email)
      end
      if options["role"] == "true"
        tcsv.push(user.role.name)
      end
      if options["parent"] == "true"
        tcsv.push(user.parent.name)
      end
      if options["email_options"] == "true"
        tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review)
      end
      if options["handle"] == "true"
        tcsv.push(part.handle)
      end
      csv << tcsv
    }
  end

  def self.export_fields(options)
    return User.export_fields(options)
  end

end
