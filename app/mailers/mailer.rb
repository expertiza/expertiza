# app/mailers/mailer.rb
class Mailer < GenericMailer
  def delayed_message(defn)
    subject = defn[:subject]
    body = defn[:body]
    bcc = defn[:bcc]

    send_email(subject, nil, body, bcc: bcc)
  end

  def email_author_reviewers(subject, body, email)
    send_email(subject, email, body)
  end

  def generic_message(defn)
    @partial_name = defn[:body][:partial_name]
    @user = defn[:body][:user]
    @first_name = defn[:body][:first_name]
    @password = defn[:body][:password]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]
    @conference_variable = defn[:body][:conference_variable]

    send_email(defn[:subject], defn[:to], render_to_string(partial: 'generic_message'))
  end
  
end
