# app/mailers/request_mailer.rb
class RequestMailer < GenericMailer
    def request_user(defn)
      @user = defn[:body][:user]
      @super_user = defn[:body][:super_user]
      @first_name = defn[:body][:first_name]
      @new_pct = defn[:body][:new_pct]
      @avg_pct = defn[:body][:avg_pct]
      @assignment = defn[:body][:assignment]
  
      send_email(defn[:subject], defn[:to], render_to_string(partial: 'request/user_request'), bcc: defn[:bcc])
    end
  end
  