desc "Send email reminders to all students with upcoming assignment deadlines"
task :send_email_reminders => :environment do
        # find all assignments in database                
  #allAssign = Assignment.al
        #query to pick only those assignments that were created in the last 2 weeks - to avoid picking all assignments
        assignments = Assignment.find(:all, :include => {:participants => :user}, :conditions => ["created_at >= ? AND created_at <= ?", Time.now - 1209600, Time.now])
        for assign in assignments
          #fetching all due dates for the current assignment
          due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", assign.id])
          if due_dates.size > 0 #making sure that the assignmefnt does have due dates
            #the above query picks all deadlines for an asisgnment and we check for each and based on the assignment type we perform specific checks and then send email reminders
            for date in due_dates
              if (date.due_at - Time.now) <= date.threshold * 3600 && (date.due_at - Time.now) > 0 && date.flag == false #send reminder
                deadlinetype = date.deadline_type_id
                if deadlinetype == 1 #1 is submission
                  submission_reminder(assign, date)
                end
                if deadlinetype == 2 #2 is review
                  review_reminder(assign, date)
                end
                if deadlinetype == 5 #5 is for metareview
                  metareview_reminder(assign, date)
                end
                date.set_flag
              end
            end #end of for loop
          end #end of the if condition
          #MUST SET A FLAG TO INDICATE THAT REMINDERS HAVE BEEN SENT TO A PARTICIPANT OF AN ASSIGNMENT FOR A SPECIFIC ASSIGNMENT TYPE
          #ELSE THEY WILL GET SPAMMED WITH MESSAGES EVERY HOUR
        end #end 'for' loop for all assignmnets
end

  def submission_reminder(assign, due_date)
    allParticipants = assign.participants
    emails = Array.new
    Rails.logger.info "Inside submission_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    allParticipants.each do |participant|
      email = participant.user.email
      assign_name = assign.name
      if participant.submitted_at.nil? && participant.team.hyperlinks.empty? #if(participant.has_submissions == false)
        emails << email
      end
    end
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent submission reminders for assignment #{assign.name}"
  end

  def review_reminder(assign, due_date)
    participants = assign.participants
    emails = []
    Rails.logger.info "Inside review_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    participants.each do | participant |
      email = participant.user.email
      assign_name = assign.name
      response_maps = participant.review_mappings
      if response_maps.size > 0
         response_maps.each do | response_map |
            response = response_map.response.last
            resubmission_times = ResubmissionTime.find(:all, :conditions => ["participant_id = ?", response_map.reviewee_id], :order => "resubmitted_at DESC")
            unless response.nil? || resubmission_times.size <= 0 #meaning the reviewer has submitted a response for that map_id
              if response.updated_at < resubmission_times[0].resubmitted_at #participant/reviewer has reviewed an older version
                  emails << email
            elsif response.nil?  #where the reviewee has submitted and reviewer has provided no response
              #noinspection RubyParenthesesAroundConditionInspection
              if resubmission_times.size > 0
                emails << email
              else #if the reviewee has made some sort of submission
                reviewee = response_map.reviewee
                unless reviewee[0].submitted_at.nil? && reviewee[0].team.hyperlinks.empty?
                  emails << email
                end
              end
           end
        end #endof the response maps loop
      end
    end #end of the for loop for all participants of the assignment
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent review reminders for assignment #{assign.name}"
  end

  def metareview_reminder(assign, due_date)
    participants = assign.participants
    emails = []
    Rails.logger.info "Inside metareview_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    participants.each do | participant |
      email = participant.user.email
      assign_name = assign.name
      response_maps = participant.metareview_mappings
      if response_maps.size > 0
        response_maps.each do | response_map |
            #checking to see if the response map was for a review in the same assignment
            check_response_map = ResponseMap.find(:all, :conditions => ["id = ? AND type = 'ParticipantReviewResponseMap' AND reviewed_object_id = ?", response_map.reviewed_object_id, assign.id])
            if check_response_map.size > 0
              if response_map.response.empty?
                emails << email
              end
            end
        end
      end
    end #end of the for loop
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent metareview reminders for assignment #{assign.name}"
  end

  def email_remind(emails, assign_name, due_date, assign_type)
      due_date_string = due_date.due_at.to_s
      subject = "Message regarding #{assign_type} for #{assign_name}"
      if assign_type == "submission"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end
      if assign_type == "review"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end
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
