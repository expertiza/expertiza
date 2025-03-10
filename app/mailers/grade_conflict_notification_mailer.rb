# app/mailers/grade_conflict_notification_mailer.rb
class GradeConflictNotificationMailer < GenericMailer
    def notify_grade_conflict(defn)
      @body = defn[:body]
  
      @assignment = @body[:assignment]
      @reviewer_name = @body[:reviewer_name]
      @type = @body[:type]
      @reviewee_name = @body[:reviewee_name]
      @new_score = @body[:new_score]
      @conflicting_response_url = @body[:conflicting_response_url]
      @summary_url = @body[:summary_url]
      @assignment_edit_url = @body[:assignment_edit_url]
  
      send_email(defn[:subject], defn[:to], render_to_string(partial: 'notification/grade_conflict'), bcc: defn[:bcc])
    end
  
    def notify_review_rubric_change(defn)
      @body = defn[:body]
      @answers = defn[:body][:answers]
      @name = defn[:body][:name]
      @assignment_name = defn[:body][:assignment_name]
  
      send_email(defn[:subject], defn[:to], render_to_string(partial: 'notification/review_rubric_change'), bcc: defn[:bcc])
    end
  end
  