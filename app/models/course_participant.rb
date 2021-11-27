class CourseParticipant < Participant
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'
  # Copy this participant to an assignment
  def copy(assignment_id)
    part = AssignmentParticipant.where(user_id: self.user_id, parent_id: assignment_id).first
    if part.nil?
      part = AssignmentParticipant.create(user_id: self.user_id, parent_id: assignment_id)
      part.set_handle
      part
    else
      nil # return nil so we can tell a copy is not made
    end
  end

  def self.import(row_hash, session, id)
    byebug
    raise ArgumentError, "The record does not have enough items." if row_hash.length < self.required_import_fields.length
    user = User.find_by(name: row_hash[:name])
    user = User.import(row_hash, session, nil) if user.nil?

    user = User.find_by(name: row_hash[:name])
    if user.nil?
      raise ArgumentError, "The record containing #{row_hash[:name]} does not have enough items." if row_hash.length < 4
      attributes = ImportFileHelper.define_attributes(row_hash)
      user = ImportFileHelper.create_new_user(attributes, session)
    end

    course = Course.find_by(id)
    raise ImportError, "The course with id " + id.to_s + " was not found." if course.nil?
    unless CourseParticipant.exists?(user_id: user.id, parent_id: id)
      CourseParticipant.create(user_id: user.id, parent_id: id)
    end
  end

  def self.required_import_fields
    {"name" => "Name",
     "fullname" => "Full Name",
     "email" => "Email"}
  end

  def self.optional_import_fields(id=nil)
    {}
  end

  def self.import_options
    {}
  end

  def path
    Course.find(self.parent_id).path + self.directory_num.to_s + "/"
  end
end
