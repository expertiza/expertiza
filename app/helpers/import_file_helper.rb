require 'csv'

module ImportFileHelper
  def self.define_attributes(row)
    attributes = {
        role_id: Role.student.id,
        name: row[0].strip,
        fullname: row[1],
        email: row[2].strip,
        email_on_submission: 1,
        email_on_review: 1,
        email_on_review_of_review: 1
    }
    attributes
  end

  def self.create_new_user(attributes, session)
    user = User.new(User.user_params(attributes))
    user.parent_id = (session[:user]).id
    user.timezonepref = User.find(user.parent_id).timezonepref
    user.save!
    user
  end
end
