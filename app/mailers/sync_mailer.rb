# app/mailers/sync_mailer.rb
class SyncMailer < GenericMailer
    def sync_message(defn)
      @body = defn[:body]
      @type = defn[:body][:type]
      @obj_name = defn[:body][:obj_name]
      @link = defn[:body][:link]
      @first_name = defn[:body][:first_name]
      @partial_name = defn[:body][:partial_name]
  
      send_email(defn[:subject], defn[:to], render_to_string(partial: 'sync/message'), bcc: defn[:bcc])
    end
  end
  