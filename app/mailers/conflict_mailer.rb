class ConflictMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.conflict_mailer.send_conflict_email.subject
  #
  def send_conflict_email(sender,recipient,participant,score)
      @assignment=Assignment.find(participant.parent_id)
      @recipient=recipient
      @participant=participant
      @score=score
      if recipient.role_id==1
        @role = "reviewer"
        @item = "submission"
      else
        @role = "metareviewer"
        @item = "review"
      end
    mail subject: "Conflication Email",to: "jgu7@ncsu.edu"
  end


  def get_body_text(submission)
    if submission
      role = "reviewer"
      item = "submission"
    else
      role = "metareviewer"
      item = "review"
    end
    "Hi ##[recipient_name],

        You submitted a score of ##[recipients_grade] for assignment ##[assignment_name] that varied greatly from another "+role+"'s score for the same "+item+".

        The Expertiza system has brought this to my attention."
  end
end
