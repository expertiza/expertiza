module Import
  def self.import(row, _row_header = nil, session, id)
    raise ArgumentError, "No user id has been specified." if row.empty?
    user = User.find_by_name(row[0])
    if user.nil?
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
    raise ImportError, "The assignment with id \"" + id.to_s + "\" was not found." if Assignment.find(id).nil?
    unless AssignmentParticipant.exists?(user_id: user.id, parent_id: id)
      new_part = AssignmentParticipant.create(user_id: user.id, parent_id: id)
      new_part.set_handle
    end
  end
end