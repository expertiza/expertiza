class CourseParticipant < Participant
  belongs_to :course, class_name: 'Course', foreign_key: 'parent_id'
  # Copy this participant to an assignment
  def copy(assignment_id)
    part = AssignmentParticipant.where(user_id: user_id, parent_id: assignment_id).first
    if part.nil?
      part = AssignmentParticipant.create(user_id: user_id, parent_id: assignment_id)
      part.set_handle
      part
    end
  end

  # provide import functionality for Course Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row_hash, _row_header = nil, session, id)
    raise ArgumentError, 'No user id has been specified.' if row_hash.empty?

    user = User.find_by(name: row_hash[:name])
    if user.nil?
      raise ArgumentError, "The record containing #{row_hash[:name]} does not have enough items." if row_hash.length < 4

      attributes = ImportFileHelper.define_attributes(row_hash)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
    course = Course.find(id)
    raise ImportError, 'The course with the id "' + id.to_s + '" was not found.' if course.nil?

    unless CourseParticipant.exists?(user_id: user.id, parent_id: id)
      CourseParticipant.create(user_id: user.id, parent_id: id)
    end
  end

  def path
    Course.find(parent_id).path + directory_num.to_s + '/'
  end
end
