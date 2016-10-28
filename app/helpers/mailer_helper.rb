module MailerHelper
  def self.send_mail_to_user(user, subject, partial_name, password)
    Mailer.generic_message ({
      to: user.email,
      subject: subject,
      body: {
        user: user,
        password: password,
        first_name: ApplicationHelper.get_user_first_name(user),
        partial_name: partial_name
      }
    })
  end

  def self.send_mail_to_reviewer(user, subject, partial_name, type, obj_name)
    Mailer.sync_message ({
      to: user.email,
      subject: subject,
      body: {
        type: type,
        obj_name: obj_name,
        user: user,
        first_name: ApplicationHelper.get_user_first_name(user),
        partial_name: partial_name
      }
    })
  end

  def self.send_mail_for_invitation(user, subject, partial_name, type, obj_name)
    Mailer.sync_message ({
      to: user.email,
      subject: subject,
      body: {
        type: type,
        obj_name: obj_name,
        user: user,
        first_name: ApplicationHelper.get_user_first_name(user),
        partial_name: partial_name
      }
    })
  end

def self.send_mail_for_advertisement_response(user, subject, partial_name, type, obj_name)
    Mailer.sync_message ({
      to: user.email,
      subject: subject,
      body: {
        type: type,
        obj_name: obj_name,
        user: user,
        first_name: ApplicationHelper.get_user_first_name(user),
        partial_name: partial_name
      }
    })
  end
 
end
