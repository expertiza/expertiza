class CoursesUsers < ActiveRecord::Base
  # provide import functionality for Course Users
  # if user does not exist, it will be created and added to this course
  def self.import(row, session, id)
    raise ArgumentError, "Not enough items" if row.length != 4
    user = User.find_by_name(row[0])
    if user.nil?
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
    raise MissingObjectIDError if id == nil
    course = Course.find(id)
    if course.nil?
      raise ImportError, "The course with the id \"" + id.to_s + "\" was not found."
    end
    if CoursesUsers.where(['user_id=? AND course_id=?', user.id, course.id]).count.zero?
      CoursesUsers.create user_id: user.id, course_id: course.id
    end
  end

  def email(pw, home_page)
    user = User.find(self.user_id)
    course = Course.find(self.course_id)
    Mailer.sync_message(
      recipients: user.email,
       subject: "You have been registered as a participant in #{course.title}",
       body: {
         home_page: home_page,
         user_name: ApplicationHelper.get_user_first_name(user),
         name: user.name,
         password: pw,
         partial_name: "register"
       }
    ).deliver
  end
end
