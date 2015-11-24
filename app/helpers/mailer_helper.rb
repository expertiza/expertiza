module MailerHelper
  def self.send_mail_to_user(user,subject,partial_name,link=nil)
    Mailer.generic_message ({
      :to => user.email,
      :subject => subject,
      :body => {
        :user         => user,
        :link         => link,
        :first_name   => ApplicationHelper::get_user_first_name(user),
        :partial_name => partial_name
      }
    })
  end
end
