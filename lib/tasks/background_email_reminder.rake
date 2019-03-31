desc "Send email reminders to all students with upcoming assignment deadlines"
task :send_email_reminders => :environment do
        allAssign = Assignment.find(:all, :include => {:participants => :user}, :conditions => ["created_at >= ? AND created_at <= ?", Time.now - 1209600, Time.now])
        for assign in allAssign

          due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", assign.id])


          if(due_dates.size > 0)
            for date in due_dates

              if((date.due_at - Time.now) <= date.threshold * 3600 && (date.due_at - Time.now) > 0 && date.flag == false)

                deadlinetype = date.deadline_type_id
                if deadlinetype == 1
                  submission_reminder(assign, date)

                end
                if deadlinetype == 2
                  review_reminder(assign, date)
                end
                if deadlinetype == 5
                  metareview_reminder(assign, date)
                end

                date.set_flag
              end
            end
          end
        end
end

  def submission_reminder(assign, due_date)
    allParticipants = assign.participants
    emails = Array.new
    Rails.logger.info "Inside submission_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    for participant in allParticipants
      email = participant.user.email

      assign_name = assign.name

      if (participant.submitted_at.nil? && participant.team.hyperlinks.empty?)#if(participant.has_submissions == false)
        emails << email
      end
    end
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent submission reminders for assignment #{assign.name}"
  end

  def review_reminder(assign, due_date)
    allParticipants = assign.participants
    Rails.logger.info "Inside review_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    assign_name = assign.name
    email_list = []
    for participant in allParticipants
      email = participant.user.email
      allresponsemaps = participant.review_mappings
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
          response = eachresponsemap.response.last
          resubmission_times = ResubmissionTime.find(:all, :conditions => ["participant_id = ?", eachresponsemap.reviewee_id], :order => "resubmitted_at DESC")
          if(!response.nil? && resubmission_times.size > 0)
            if(response.updated_at < resubmission_times[0].resubmitted_at)
                email_list << { 'email' => email, 'response_id' => response.id }
            end
          elsif(response.nil?)
            if(resubmission_times.size > 0)
              email_list << { 'email' => email, 'response_id' => response.id }
            else
              reviewee = eachresponsemap.reviewee
              unless (reviewee[0].submitted_at.nil? && reviewee[0].team.hyperlinks.empty?)
                email_list << { 'email' => email, 'response_id' => response.id }
              end
            end
          end
        end
      end
    end

    # Spring 19 AHP
    send_reminder_emails(email_list, assign_name, due_date, assign_type)
    Rails.logger.info "Sent review reminders for assignment #{assign.name}"
  end

  def metareview_reminder(assign, due_date)
    allParticipants = assign.participants
    emails = Array.new
    Rails.logger.info "Inside metareview_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name

    for participant in allParticipants
      email = participant.user.email

      assign_name = assign.name

      allresponsemaps = participant.metareview_mappings
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps

            checkresponsemap = ResponseMap.find(:all, :conditions => ["id = ? AND type = 'ParticipantReviewResponseMap' AND reviewed_object_id = ?", eachresponsemap.reviewed_object_id, assign.id])
            if(checkresponsemap.size > 0)
              if eachresponsemap.response.empty?
                emails << email
              end
            end
        end
      end
    end
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent metareview reminders for assignment #{assign.name}"
  end

  # Spring 19 AHP
  def send_reminder_emails(email_list, assign_name, due_date, assign_type)
    due_date_string = due_date.due_at.to_s
    subject = "Message regarding #{assign_type} for #{assign_name}"
    for item in email_list
      body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. " +
          "Deadline is #{due_date_string}. " +
          "Please visit https://expertiza.ncsu.edu/response/edit?id=#{item.response_id}"
      Mailer.deliver_message({ :bcc => [item.email], :subject => subject, :body => body })
    end
  end

  def email_remind(emails, assign_name, due_date, assign_type)

      due_date_string = due_date.due_at.to_s
      subject = "Message regarding #{assign_type} for #{assign_name}"
      if assign_type == "submission"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end

      # Spring 19 AHP
      if assign_type == "metareview"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end
      Mailer.deliver_message(
        {:bcc => emails,
         :subject => subject,
         :body => body
        })
  end

  def email_start(emails, assign_name)
      subject = "Message regarding new assignment"
      body = "Hi, #{assign_name} has just been created."
      Mailer.deliver_message(
        {:bcc => emails,
         :subject => subject,
         :body => body
        })
  end
