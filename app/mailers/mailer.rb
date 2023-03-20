# frozen_string_literal: true

class Mailer < ActionMailer::Base
  if Rails.env.development? || Rails.env.test?
    default from: 'expertiza.debugging@gmail.com'
  else
    default from: 'expertiza-support@lists.ncsu.edu'
  end

  # Sends emails to both authors or reviewers.
  def email_author_reviewers(subject, body, email)
    Rails.env.development? || Rails.env.test? ? @email = 'expertiza.debugging@gmail.com' : @email = email
    mail(to: @email,
         body: body,
         content_type: 'text/html',
         subject: subject)
  end

  # This method is used to request a message to a user by passing the super_user details, user name and the email subject.
  def request_user_message(defn)
    @user = defn[:body][:user]
    @super_user = defn[:body][:super_user]
    @first_name = defn[:body][:first_name]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end

  # Ensures emails are being sent upon a submission via the sync_message protocol.
  def sync_message(defn)
    @body = defn[:body]
    @type = defn[:body][:type]
    @obj_name = defn[:body][:obj_name]
    @link = defn[:body][:link]
    @first_name = defn[:body][:first_name]
    @partial_name = defn[:body][:partial_name]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to])
  end

  # Contains the subect and body of the message.
  def delayed_message(defn)
    ret = mail(subject: defn[:subject],
               body: defn[:body],
               content_type: 'text/html',
               bcc: defn[:bcc])
    ExpertizaLogger.info(ret.encoded.to_s)
  end

  # Ensures an email is sent upon approval of a suggested topic.
  def suggested_topic_approved_message(defn)
    @body = defn[:body]
    @topic_name = defn[:body][:approved_topic_name]
    @proposer = defn[:body][:proposer]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:cc])
  end

  # Ensures an email is sent when a score is outside the acceptable value.
  def notify_grade_conflict_message(defn)
    @body = defn[:body]

    @assignment = @body[:assignment]
    @reviewer_name = @body[:reviewer_name]
    @type = @body[:type]
    @reviewee_name = @body[:reviewee_name]
    @new_score = @body[:new_score]
    @conflicting_response_url = @body[:conflicting_response_url]
    @summary_url = @body[:summary_url]
    @assignment_edit_url = @body[:assignment_edit_url]

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to])
  end

  # Email about a review rubric being changed. If this is successful, then the answers are deleted for a user's response
  def notify_review_rubric_change(defn)
    @body = defn[:body]
    @answers = defn[:body][:answers]
    @name = defn[:body][:name]
    @assignment_name = defn[:body][:assignment_name]
    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to])
  end
end
