module MailerHelper
  # @param user [Object]
  # @param subject [Object]
  # @param partial_name [Object]
  # MailerHelper which takes the subject, partial name and password and sends the mail to user with this information.
  def self.send_mail_to_user(user,subject,partial_name,password)

    return Mailer.deliver_message({
      :recipients => user.email,
        :subject   => subject,
        :body      => {
          :user         => user,
          :password     => password,
          :first_name   => ApplicationHelper::get_user_first_name(user),
          :partial_name => partial_name
        }
      }
    )
  end
end
