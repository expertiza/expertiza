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

  def self.send_mail_to_reviewer(user, bcc_mail_address, subject, partial_name, note)
    Mailer.new_review_request_message ({
        to: user.email,
        bcc: bcc_mail_address,
        subject: subject,
        body: {
            user: user,
            first_name: ApplicationHelper.get_user_first_name(user),
            message: note,
            partial_name: partial_name
        }
    })
  end

  def self.send_mail_to_all_super_users(super_user, user, subject)
    Mailer.request_user_message ({
      to: super_user.email,
      subject: subject,
      body: {
        super_user: super_user,
        user: user,
        first_name: ApplicationHelper.get_user_first_name(super_user)
      }
    })
  end
end
