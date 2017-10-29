class CourseParticipant < Participant
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'

  # Copy this participant to an assignment
  def copy(assignment_id)
    part = AssignmentParticipant.where(user_id: self.user_id, parent_id: assignment_id).first
    if part.nil?
      part = AssignmentParticipant.create(user_id: self.user_id, parent_id: assignment_id)
      part.set_handle
      return part
    else
      return nil # return nil so we can tell a copy is not made
    end
  end

  # provide import functionality for Course Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row, _row_header = nil, session, id)
    raise ArgumentError, "No user id has been specified." if row.empty?
    user = User.find_by_name(row[0])
    if user.nil?
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
    course = Course.find(id)
    if course.nil?
      raise ImportError, "The course with the id \"" + id.to_s + "\" was not found."
    end
    unless CourseParticipant.exists?(user_id: user.id, parent_id: course.id)
      CourseParticipant.create(user_id: user.id, parent_id: course.id)
    end
  end

  def path
    Course.find(self.parent_id).path + self.directory_num.to_s + "/"
  end
end
