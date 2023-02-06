# frozen_string_literal: true

class Mailer < ActionMailer::Base
  if Rails.env.development? || Rails.env.test?
    default from: 'expertiza.debugging@gmail.com'
  else
    default from: 'expertiza-support@lists.ncsu.edu'
  end

  def email_author_reviewers(subject, body, email)
    Rails.env.development? || Rails.env.test? ? @email = 'expertiza.debugging@gmail.com' : @email = email
    mail(to: @email,
         body: body,
         content_type: 'text/html',
         subject: subject)
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

    if Rails.env.development? || Rails.env.test?
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
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
      defn[:to] = 'expertiza.debugging@gmail.com'
    end
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end

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

  def delayed_message(defn)
    ret = mail(subject: defn[:subject],
               body: defn[:body],
               content_type: 'text/html',
               bcc: defn[:bcc])
    ExpertizaLogger.info(ret.encoded.to_s)
  end

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

  # If the user submits a suggestion and gets it approved -> Send email
  # If user submits a suggestion anonymously and it gets approved -> DOES NOT get an email
  def notify_suggestion_approval(used_id, team_id, suggestion_title)
    proposer = User.find_by(id: user_id)
    if proposer
      teams_users = TeamsUser.where(team_id: team_id)
      cc_mail_list = []
      teams_users.each do |teams_user|
        cc_mail_list << User.find(teams_user.user_id).email if teams_user.user_id != proposer.id
      end
      suggested_topic_approved_message(
        to: proposer.email,
        cc: cc_mail_list,
        subject: "Suggested topic '#{suggestion_title}' has been approved",
        body: {
          approved_topic_name: suggestion_title,
          proposer: proposer.name
        }
      ).deliver_now!
    end
  end
end
