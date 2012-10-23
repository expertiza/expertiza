desc "Send email reminders to all students with upcoming assignment deadlines"
task :send_email_reminders => :environment do
        #puts "~~~~~~~~~~Spawn Running, time.now is #{Time.now}\n"
        # find all assignments in database                
        #allAssign = Assignment.find(:all)
        #query to pick only those assignments that were created in the last 2 weeks - to avoid picking all assignments
        allAssign = Assignment.find(:all, :include => {:participants => :user}, :conditions => ["created_at >= ? AND created_at <= ?", Time.now - 1209600, Time.now]) 
        for assign in allAssign
          #puts "~~~~~~~~~~assignment name #{assign.name}, id #{assign.id}"
          #puts "~~~~~~~~~~Enter assignment #{assign.name}, time.now is #{Time.now}\n and assign.created_at #{assign.created_at} and diff #{(Time.now - 14400) - assign.created_at}\n"
          
#          if((((Time.now - 14400) - assign.created_at) <= 3600) && (((Time.now - 14400) - assign.created_at) >= 0))#if any assignment was created in the last 1hr
#            # get all participants
#                #puts "looking for participants"
#            allParticipants = assign.participants
#                #puts "~~~~~~~~~~Participants found"
#            for participant in allParticipants
#                userInfo = participant.user
#                # get users full name
#                fullname = userInfo.fullname    
#                #puts "~~~~~~~~~~Participant name: #{fullname}\n"
#                
#                # get users email address
#                email    = userInfo.email      
#                #puts "~~~~~~~~~~Email: #{email}\n"
#                
#                # get name of assignment
#                assign_name = assign.name
#                #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                
#                
#                email_start(fullname, email, assign_name)
#            end 
#         end #end for the 'if' condition

          #puts "Before get_current_due_date()\n"
          #due_date = assign.find_current_stage()#get_current_due_date()
          #puts "~~~~~~~~~~Assignment: #{assign.name}, Due date: #{due_date.due_at}, Time now: #{Time.now}\n"
          #puts "~~~~~~~~~~Current Stage: #{DeadlineType.find(due_date.deadline_type_id).name}\n"
          
          #fetching all due dates for the current assignment
          due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", assign.id])
          #puts "~~~~~~~~~~~~~~~~~~~~~due dates size #{due_dates.size} and due_at #{due_dates[0].due_at} and date.due_at - Time.now is #{due_dates[0].due_at - (Time.now-14400)}\n"
          
          if(due_dates.size > 0)#making sure that the assignmefnt does have due dates
            #the above query picks all deadlines for an asisgnment and we check for each and based on the assignment type we perform specific checks and then send email reminders
            for date in due_dates 
              #puts "~~~~~~~~~~Date is: #{date.due_at} and date.due_at - Time.now is: #{date.due_at - Time.now} and flag is #{date.flag}\n"
              if((date.due_at - Time.now) <= date.threshold * 3600 && (date.due_at - Time.now) > 0 && date.flag == false)#send reminder
                #puts "~~~~~~~~~~Deadline type is: #{date.deadline_type_id} threshold is: #{date.threshold}\n"
                deadlinetype = date.deadline_type_id
                if deadlinetype == 1 #1 is submission
                  submission_reminder(assign, date)
                  #puts "~~~~~~~~~~back here!"
                end
                if deadlinetype == 2 #2 is review
                  review_reminder(assign, date)
                end
                if deadlinetype == 5 #5 is for metareview
                  metareview_reminder(assign, date)
                end
                #puts "~~~~~~~~~~~~~setting flag"
                date.setFlag
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
    for participant in allParticipants 
      email = participant.user.email
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
      #puts "~~~~~~~~~~Sending submission_reminder if no submissions found ... submitted at nil #{(participant.submitted_at == nil)} .. hyperlink nil #{participant.submitted_hyperlink == nil} hyperlink empty #{participant.submitted_hyperlink != ""}\n"
      if (participant.submitted_at.nil? && participant.get_hyperlinks.empty?)#if(participant.has_submissions == false)
        emails << email
      end
    end#end of for loop
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent submission reminders for assignment #{assign.name}"
  end

  def review_reminder(assign, due_date)
    allParticipants = assign.participants
    emails = Array.new
    Rails.logger.info "Inside review_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
    for participant in allParticipants                
      email = participant.user.email
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      #check if the participant/reviewer has reviewed the latest version of the resubmitted file, else send him a reminder
      allresponsemaps = participant.review_mappings
      #puts" ~~~~~number of response maps #{allresponsemaps.size}\n"
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            response = eachresponsemap.response
            resubmission_times = ResubmissionTime.find(:all, :conditions => ["participant_id = ?", eachresponsemap.reviewee_id], :order => "resubmitted_at DESC")           
            #puts" ~~~~~resubmission times: #{resubmission_times.size}\n"
            if(!response.nil? && resubmission_times.size > 0)#meaning the reviewer has submitted a response for that map_id  
              if(response.updated_at < resubmission_times[0].resubmitted_at) #participant/reviewer has reviewed an older version
                  emails << email
              end
            elsif(response.nil?) #where the reviewee has submitted and reviewer has provided no response
              if(resubmission_times.size > 0)
                emails << email
              else #if the reviewee has made some sort of submission
                reviewee = eachresponsemap.reviewee
                #puts "~~~~~~~~~~Sending review_reminder if no responses found ... submitted at nil #{(reviewee[0].submitted_at == nil)} .. hyperlink nil #{reviewee[0].submitted_hyperlink == nil} hyperlink empty #{reviewee[0].submitted_hyperlink == ""}\n"
                unless (reviewee[0].submitted_at.nil? && reviewee[0].get_hyperlinks.empty?)
                  #puts "~~~~~~~~~~Email: #{email}\n"   
                  emails << email
                end
              end
           end
        end #endof the response maps loop
      end
    end #end of the for loop for all participants of the assignment
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent review reminders for assignment #{assign.name}"
  end

  def metareview_reminder(assign, due_date)
    allParticipants = assign.participants
    emails = Array.new
    Rails.logger.info "Inside metareview_reminder for assignment #{assign.name}"
    assign_type = DeadlineType.find(due_date.deadline_type_id).name
    #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
    for participant in allParticipants               
      email = participant.user.email
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      #check if the participant/reviewer has completed the meta-review
      #puts "~~~~~~~~~participant id #{participant.id}"
      allresponsemaps = participant.metareview_mappings
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            #checking to see if the response map was for a review in the same assignment
            checkresponsemap = ResponseMap.find(:all, :conditions => ["id = ? AND type = 'ParticipantReviewResponseMap' AND reviewed_object_id = ?", eachresponsemap.reviewed_object_id, assign.id])
            if(checkresponsemap.size > 0)
              if eachresponsemap.response.nil?
                emails << email
              end
            end
        end
      end
    end #end of the for loop
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    Rails.logger.info "Sent metareview reminders for assignment #{assign.name}"
  end

  def email_remind(emails, assign_name, due_date, assign_type)
      #puts "~~~~~~~~~~~~~inside email reminder email #{emails}"
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
