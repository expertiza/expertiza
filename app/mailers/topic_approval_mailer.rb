# app/mailers/topic_approval_mailer.rb
class TopicApprovalMailer < GenericMailer

    def suggested_topic_approved_message(defn)
        @body = defn[:body]
        @topic_name = defn[:body][:approved_topic_name]
        @proposer = defn[:body][:proposer]

        send_email(defn[:subject], defn[:to], render_to_string(partial: 'request/user_request'), bcc: defn[:bcc])
      end
  end
  