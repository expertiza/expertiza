class Mailer < ActionMailer::Base
  default from: 'expertiza-support@lists.ncsu.edu'
  default delivery_method: :test if Rails.env.development? || Rails.env.test?

  def generic_message(defn)
    @partial_name = defn[:body][:partial_name]
    @user = defn[:body][:user]
    @first_name = defn[:body][:first_name]
    @password = defn[:body][:password]

    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end
end
