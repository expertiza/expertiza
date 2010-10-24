include ActionController
include ActiveRecord

module SpawnHelper
  COMPLETE = "Complete"
  
  def background()               
    # thread for deadline emails
    spawn do        
      while true do        
        #puts "~~~~~~~~~~Spawn Running, time.now is #{Time.now}\n"
        notification_set = Notification.find(:all)
        for notification_description in notification_set
          #If a particular notification event causes exceptions, catch them in here so they don't interfere with other notifications
          begin
            # DEBUG: puts "Sending Notifications: " + notification_description.description
            meta_conditions = MetaCondition.find_all_by_notification_id(notification_description.id)
            notification_message = NotificationMessage.find_by_id(notification_description.notification_message_id)

            # build array of all variables required for the message
            vars_required = ["users.email"]
            message_vars_required = notification_message.variables.split(',')
            for message_var_required in message_vars_required
             #skip any field that includes "users.email" since we assume that is always required
              if(message_var_required != "users.email")
                vars_required << message_var_required
              end
            end

            # extract the data for every notification that needs to be send for this event
            query_result = find_entries_meeting_conditions(notification_description.base_data_type, notification_description.relationship, meta_conditions, vars_required)

            for message_data in query_result
              # replace message placeholders with values
              populated_message = fill_placeholders(notification_message.body, message_data)

              # send message to the mailer
              #DEBUG: puts "To: " + message_data["users_email"]
              #DEBUG: puts "Subject: " + notification_message.subject
              #DEBUG: puts "Body: "  + populated_message
              Mailer.deliver_message(
                {:recipients => message_data["users_email"],
                 :subject => notification_message.subject,
                 :body => populated_message
              })
            end
          rescue
            puts "ERROR Sending Notification: " + notification_description.description
          end
        end

        sleep 3600 #sleeps for 1 hour after all reminders have been sent
      end #end of 'while' loop
    end #end of spawn do loop
  end #end of 'def'
end #end of class