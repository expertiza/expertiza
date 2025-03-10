# app/mailers/notification_mailer.rb
class RubricChangeNotificationMailer < GenericMailer
  
    def notify_review_rubric_change(defn)
      @body = defn[:body]
      @answers = defn[:body][:answers]
      @name = defn[:body][:name]
      @assignment_name = defn[:body][:assignment_name]
  
      send_email(defn[:subject], defn[:to], render_to_string(partial: 'notification/review_rubric_change'), bcc: defn[:bcc])
    end
  end
  