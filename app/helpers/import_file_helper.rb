require 'csv'

module ImportFileHelper
  def self.define_attributes(row)
    attributes = {}
    attributes["role_id"] = Role.student.id
    attributes["name"] = row[0].strip
    attributes["fullname"] = row[1]
    attributes["email"] = row[2].strip
    attributes["email_on_submission"] = 1
    attributes["email_on_review"] = 1
    attributes["email_on_review_of_review"] = 1
    attributes
  end

  def self.create_new_user(attributes, session)
    user = User.new(attributes)
    user.parent_id = (session[:user]).id
    user.timezonepref = User.find(user.parent_id).timezonepref
    user.save!
    user
    instructor_email = User.where(["role_id = ?", 2]).select("email").first
    send_email_to_instructor(instructor_email)
  end

  def send_email_to_instructor(instructor_email)
    Mailer.suggested_topic(
        to: instructor_email,
        #cc: cc_mail_list,
        subject: "A new topic named '#{@suggestion.title}' has been suggested",
        body: {
            suggested_topic_name: @suggestion.title,
            proposer: @user_id
        }
    ).deliver_now!
    end
end
