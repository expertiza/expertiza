# app/mailers/reminder_mailer.rb
class ReminderMailer < GenericMailer
    def assignment_reminder(assignment_name, deadline_type, participant_assignment_id, due_at, email)
      body = build_reminder_body(assignment_name, deadline_type, participant_assignment_id, due_at)
      subject = "Reminder: #{deadline_type} for assignment #{assignment_name}"
  
      send_email(subject, email, body)
    end
  
    private
  
    def build_reminder_body(assignment_name, deadline_type, participant_assignment_id, due_at)
      link_to_destination = "Please follow the link: http://expertiza.ncsu.edu/student_task/view?id=#{participant_assignment_id}\n"
      "This is a reminder to complete #{deadline_type} for assignment #{assignment_name}.\n" +
      link_to_destination +
      "Deadline is #{due_at}. If you have already done the #{deadline_type}, then please ignore this mail."
    end
  end
  