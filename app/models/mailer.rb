class Mailer < ActionMailer::Base
  @redirectURL = ""
  #Creates message content
  #defn - A hash object containing the following items:
  #    subject - message's subject line
  #    recipients - a string or array containing the recipient e-mail 
  #                 address(es)
  #    bcc <optional> - a string or array containing the bcc e-mail
  #                 address(es)
  #    body - a hash containing the following:
  #           partial_name - the name of the partial located in 
  #               /app/views/mailer/partials to use when rendering
  #               this message. Do not include the message type (_html or _plain)
  #           <optional> Other content can be included as needed by the partial
  def message(defn)
     @subject = defn[:subject]
     @recipients = defn[:recipients]
     if defn[:bcc] != nil
       @bcc = defn[:bcc]
     end
     @from = "expertiza-support@lists.ncsu.edu"
     @body = defn[:body]
     @url = defn[:url]
     @sent_on = Time.now 
     @content_type = 'text/html'

     @controller = defn[:controller]
     @action = defn[:action]
     @assignmentID = defn[:assignmentID]
     @host = self.hostName

     @redirectURL = @host.to_s
     @redirectURL << @controller.to_s
     @redirectURL << "/"
     @redirectURL << @action.to_s
     @redirectURL << "/"
     @redirectURL << @assignmentID.to_s

     p "redirect : #{@redirectURL}"
  end
end
