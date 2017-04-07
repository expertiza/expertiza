class Mailer < ActionMailer::Base
  if Rails.env.development? || Rails.env.test?
    default from: 'expertiza.development@gmail.com'
    helper ApplicationHelper
  else
    default from: 'expertiza-support@lists.ncsu.edu'
  end

  def generic_message(defn)
    @partial_name = defn[:body][:partial_name]
    @user = defn[:body][:user]
    @first_name = defn[:body][:first_name]
    @password = defn[:body][:password]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end
    condition = User.where(["role_id = ?", 2]).select("copy_of_all_emails = ?")
    defn[:cc] = if condition == true
                  User.where(["role_id = ? and copy_of_all_emails = ?", 2, true]).select("email")
                else
                  defn[:cc] = 'expertiza.development@gmail.com'
                end

    mail(subject: defn[:subject],
         to: defn[:to],
         cc: defn[:cc],
         bcc: defn[:bcc])
  end


  def request_user_message(defn)
    @user = defn[:body][:user]
    @super_user = defn[:body][:super_user]
    @first_name = defn[:body][:first_name]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end

    mail(subject: defn[:subject],
         to: defn[:to],
         cc: defn[:cc],
         bcc: defn[:bcc])
  end

  def sync_message(defn)
    @body = defn[:body]
    @type = defn[:body][:type]
    @obj_name = defn[:body][:obj_name]
    @first_name = defn[:body][:first_name]
    @partial_name = defn[:body][:partial_name]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end
    mail(subject: defn[:subject],
         # content_type: "text/html",
         to: defn[:to])
  end

  def delayed_message(defn)
    condition = User.where(["role_id = ?", 2]).select("copy_of_all_emails = ?")
    defn[:cc] = if condition == true
                  User.where(["role_id = ? and copy_of_all_emails = ?", 2, true]).select("email")
                else
                  defn[:cc] = 'expertiza.development@gmail.com'
                end

    ret = mail(subject: defn[:subject],
               body: defn[:body],
               content_type: "text/html",
               cc: defn[:cc],
               bcc: defn[:bcc])
    CUSTOM_LOGGER.info(ret.encoded.to_s)
  end

  def suggested_topic_approved_message(defn)
    @body = defn[:body]
    @topic_name = defn[:body][:approved_topic_name]
    @proposer = defn[:body][:proposer]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:cc])
  end

  def suggested_topic(defn)
    @body = defn[:body]
    @topic_name = defn[:body][:suggested_topic]
    @proposer = defn[:body][:proposer]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:cc])
  end

  def invitation(defn)
    @body = defn[:body]
    @topic_name = defn[:body][:suggested_topic]
    @user = defn[:body]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end

    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:cc])
  end

  def notify_grade_conflict_message(defn)
    @body = defn[:body]

    @assignment = @body[:assignment]
    @reviewer_name = @body[:reviewer_name ]
    @type = @body[:type]
    @reviewee_name = @body[:reviewee_name]
    @new_score = @body[:new_score]
    @conflicting_response_url = @body[:conflicting_response_url]
    @summary_url = @body[:summary_url]
    @assignment_edit_url = @body[:assignment_edit_url]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.development@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to])
  end
end
