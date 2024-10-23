# app/mailers/generic_mailer.rb
class GenericMailer < ActionMailer::Base
    # Set the default sender email
    if Rails.env.development? || Rails.env.test?
      default from: 'expertiza.mailer@gmail.com'
    else
      default from: 'expertiza.mailer@gmail.com'
    end
  
    def send_email(subject, to, body, bcc: nil, content_type: 'text/html')
      # Override recipient email in development or test environments
      to = 'expertiza.mailer@gmail.com' if Rails.env.development? || Rails.env.test?
  
      mail(
        subject: subject,
        to: to,
        body: body,
        bcc: bcc,
        content_type: content_type
      )
    end
  end
  