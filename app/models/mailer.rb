class Mailer < ActionMailer::Base
  def message(defn)
    mail(
      :subject => defn[:subject],
      :to => defn[:recipients],
      :bcc => defn[:bcc],
      :from => 'expertiza-support@lists.ncsu.edu'
    ) do
      render :partial => defn[:body][:partial_name], :locals => defn.delete(:partial_name)
    end
  end
end
