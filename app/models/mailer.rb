class Mailer < ActionMailer::Base
  default from: 'expertiza-support@lists.ncsu.edu'

  def generic_message(defn)
    @partial_name = defn[:body][:partial_name]
    @user = defn[:body][:user]
    @first_name = defn[:body][:first_name]
    @password = defn[:body][:password]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    defn[:to] = 'expertiza@mailinator.com' if Rails.env.development? || Rails.env.test?

    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end

  def sync_message(defn)

    @body = defn[:body]
    @partial_name = defn[:body][:partial_name]
     mail(subject: defn[:subject],
          content_type: "text/html",
          to: defn[:to])

  end

  def delayed_message(defn)
    ret = mail(subject: defn[:subject],
         body: defn[:body],
         content_type: "text/html",
         bcc: defn[:bcc])
      CUSTOM_LOGGER.info("#{ret.encoded}")
  end

end
