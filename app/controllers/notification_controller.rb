class NotificationController < ApplicationController
  include NotificationHelper
  
  def sample
    notifications = Notification.find(:all)
    notifications.each do |notification|
      # DEBUG: puts "Sending Notifications: " + notification.description
      meta_conditions = MetaCondition.find_all_by_notification_id(notification.id)
      notification_message = NotificationMessage.find_by_id(notification.notification_message_id)

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
      query_result = find_entries_meeting_conditions(notification.base_data_type, notification.relationship, meta_conditions, vars_required)

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

    end
    # Send assignment due date reminders
    #sample_db_conditionStart = MetaCondition.new
    #sample_db_conditionStart.data_name = "due_dates.due_at"
    #sample_db_conditionStart.condition = ">"
    #sample_db_conditionStart.comparison_value = eval("Time.now - 2.days")

    #sample_db_conditionEnd = MetaCondition.new
    #sample_db_conditionEnd.data_name = "due_dates.due_at"
    #sample_db_conditionEnd.condition = "<"
    #sample_db_conditionEnd.comparison_value = eval("Time.now + 1.hour") # 1 hr in the future

    # @sample_out = [sample_db_conditionStart, sample_db_conditionEnd];
    #base_class = "Assignment"
    #joins_listing = "due_dates.assignment_id=assignments.id,participants.parent_id=assignments.id,users.id=participants.user_id"
    #selection_vars = ["assignments.name", "users.name", "users.email"]
    #@sample_out = find_entries_meeting_conditions(base_class, joins_listing, [sample_db_conditionStart, sample_db_conditionEnd], selection_vars)

    #puts @sample_out

    # Alerting users when they are added to an assignment
    #sample_db_conditionStart = MetaCondition.new
    #sample_db_conditionStart.data_name = "participants.created_at"
    #sample_db_conditionStart.condition = ">"
    #sample_db_conditionStart.comparison_value = eval("Time.now.getutc - 1.hour") # 1 hr in the past

    #sample_db_conditionEnd = MetaCondition.new
    #sample_db_conditionEnd.data_name = "participants.created_at"
    #sample_db_conditionEnd.condition = "<"
    #sample_db_conditionEnd.comparison_value = eval("Time.now.getutc")

    #base_class = "Participant"
    #joins_listing = "assignments.id=participants.parent_id,users.id=participants.user_id"
    #selection_vars = ["assignments.name", "users.name", "users.email"]
    #@sample_out = find_entries_meeting_conditions(base_class, joins_listing, [sample_db_conditionStart, sample_db_conditionEnd], selection_vars)

    #puts "Newly added participant:"
    #puts @sample_out

    # Alerting users when they are added to an assignment
    #sample_db_conditionStart = MetaCondition.new
    #sample_db_conditionStart.data_name = "response_maps.created_at"
    #sample_db_conditionStart.condition = ">"
    #sample_db_conditionStart.comparison_value = eval("Time.now - 1.hour") # 1 hr in the past

    #sample_db_conditionEnd = MetaCondition.new
    #sample_db_conditionEnd.data_name = "response_maps.created_at"
    #sample_db_conditionEnd.condition = "<"
    #sample_db_conditionEnd.comparison_value = eval("Time.now")

    #base_class = "ResponseMap"
    #joins_listing = "participants.user_id=response_maps.reviewer_id,users.id=participants.user_id,assignments.id=response_maps.reviewed_object_id"
    #selection_vars = ["assignments.name", "users.name", "users.email"]
    #@sample_out = find_entries_meeting_conditions(base_class, joins_listing, [sample_db_conditionStart, sample_db_conditionEnd], selection_vars)

    #puts @sample_out
    raise Exception
  end

end
