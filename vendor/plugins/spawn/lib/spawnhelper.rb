include ActionController
include ActiveRecord

module SpawnHelper
  COMPLETE = "Complete"
  
  def background()               
    # thread for deadline emails
    spawn do        
      while true do        
        #puts "~~~~~~~~~~Spawn Running, time.now is #{Time.now}\n"
        # find all assignments in database                
        allAssign = Assignment.find(:all)
        for assign in allAssign
          #puts "~~~~~~~~~~assignment name #{assign.name}"
          #puts "~~~~~~~~~~Enter assignment, time.now is #{Time.now}\n and assign.created_at #{assign.created_at} and diff #{Time.now - assign.created_at}\n"
          
          if(Time.now - assign.created_at <= 3600)#if any assignment was created in the last 1hr
            # get all participants
            allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      

            for participant in allParticipants
                # get users full name
                fullname = User.find(participant.user_id).fullname    
                #puts "~~~~~~~~~~Participant name: #{fullname}\n"
                
                # get users email address
                email    = User.find(participant.user_id).email      
                #puts "~~~~~~~~~~Email: #{email}\n"
                
                # get name of assignment
                assign_name = assign.name
                #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                
                
                email_start(fullname, email, assign_name)
            end 
         end #end for the 'if' condition

          #puts "Before get_current_due_date()\n"
          #due_date = assign.find_current_stage()#get_current_due_date()
          #puts "~~~~~~~~~~Assignment: #{assign.name}, Due date: #{due_date.due_at}, Time now: #{Time.now}\n"
          #puts "~~~~~~~~~~Current Stage: #{DeadlineType.find(due_date.deadline_type_id).name}\n"
          
          #fetching all due dates for the current assignment
          due_dates = DueDate.find(:all, 
                 :conditions => ["assignment_id = ?", assign.id])
          puts "~~~~~~~~~~~~~~~~~~~~~due dates size #{due_dates.size} and due_at #{due_dates[0].due_at} and date.due_at - Time.now is #{due_dates[0].due_at - Time.now}\n"
          
          if(due_dates.size > 0)#making sure that the assignmefnt does have due dates
            #the above query picks all deadlines for an asisgnment and we check for each and based on the assignment type we perform specific checks and then send email reminders
            for date in due_dates 
              #puts "~~~~~~~~~~Date is: #{date.due_at} and date.due_at - Time.now is: #{date.due_at - Time.now} and flag is #{date.flag}\n"
              if(date.due_at - Time.now <= date.threshold * 3600 && date.due_at - Time.now > 0 && date.flag == false)#send reminder
                #puts "~~~~~~~~~~Deadline type is: #{date.deadline_type_id} threshold is: #{date.threshold}\n"
                deadlinetype = date.deadline_type_id
                if(deadlinetype == 1)
                  submission_reminder(assign, date)
                elsif(deadlinetype == 2)#2 is review
                  review_reminder(assign, date)
                elsif(deadlinetype == 5)#5 is for metareview
                  metareview_reminder(assign, date)
                end
                date.setFlag
              end
            end #end of for loop
          end #end of the if condition
          #MUST SET A FLAG TO INDICATE THAT REMINDERS HAVE BEEN SENT TO A PARTICIPANT OF AN ASSIGNMENT FOR A SPECIFIC ASSIGNMENT TYPE
          #ELSE THEY WILL GET SPAMMED WITH MESSAGES EVERY HOUR
        end #end 'for' loop for all assignmnets
        sleep 3600 #sleeps for 1 hour after all reminders have been sent
      end #end of 'while' loop
    end #end of spawn do loop
  end #end of 'def'

  def submission_reminder(assign, due_date)
    #look for wiki submissions of each participant
    # get all participants
    #puts "~~~~~~~~~~Inside submission_reminder method\n"
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
    #puts "~~~~~~~~~~Getting All participants details:\n"
    for participant in allParticipants 
      fullname = User.find(participant.user_id).fullname    
      #puts "~~~~~~~~~~Participant name: #{fullname}\n"
                  
      email = User.find(participant.user_id).email      
      #puts "~~~~~~~~~~Email: #{email}\n"
                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"
                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"
      
        #check if he has already edited the wiki
        #if he hasn't send him an email reminder
        #puts " ~~~~~~~~~~~~~~parts.has_submissions #{participant.has_submissions} \n"
        #puts "~~~~~~~~~~Sending submission_reminder if no submissions found\n"
        if(participant.has_submissions == false)
          email_remind(fullname, email, assign_name, due_date, assign_type)
        end
    end
  end

  def review_reminder(assign, due_date)
    #look to see if the student has reviewed the latest resubmitted version before sending an email reminder
    # get all participants
    #puts "~~~~~~~~~~Inside review_reminder method\n"
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
    #puts "~~~~~~~~~~Getting All participants details:\n"
    for participant in allParticipants 
      fullname = User.find(participant.user_id).fullname    
      #puts "~~~~~~~~~~Participant name: #{fullname}\n"
                  
      email = User.find(participant.user_id).email      
      #puts "~~~~~~~~~~Email: #{email}\n"
                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"
                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"
      
      #check if the participant/reviewer has reviewed the latest version of the resubmitted file, else send him a reminder
      allresponsemaps = ResponseMap.find(:all, :conditions => ["reviewer_id = ? AND type = 'ParticipantReviewResponseMap'", participant.id])
      #puts" ~~~~~number of response maps #{allresponsemaps.size}\n"
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            allresponses = Response.find(:all, :conditions => ["map_id = ?", eachresponsemap.id])
            resubmission_times = ResubmissionTime.find(:all, :conditions => ["participant_id = ?", eachresponsemap.reviewee_id], :order => "resubmitted_at DESC")           
            if(allresponses.size > 0)#meaning the reviewer has submitted a response for that map_id  
              if(allresponses[0].updated_at < resubmission_times[0].resubmitted_at) #participant/reviewer has reviewed an older version
                  email_remind(fullname, email, assign_name, due_date, assign_type)
              end
            elsif(allresponses.size == 0 && resubmission_times.size > 0) #where the reviewee has submitted and reviewer has provided no response
              email_remind(fullname, email, assign_name, due_date, assign_type)
            end
        end #endof the response maps loop
      end
    end #end of the for loop for all participants of the assignment
  end

  def metareview_reminder(assign, due_date)
    #puts "~~~~~~~~~~Inside metareview_reminder method\n"
    # get all participants
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
    #puts "~~~~~~~~~~Getting All participants details:\n"
    for participant in allParticipants 
      fullname = User.find(participant.user_id).fullname    
      #puts "~~~~~~~~~~Participant name: #{fullname}\n"
                  
      email = User.find(participant.user_id).email      
      #puts "~~~~~~~~~~Email: #{email}\n"
                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"
                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"
      
      #check if the participant/reviewer has completed the meta-review
      allresponsemaps = ResponseMap.find(:all, :conditions => ["reviewer_id = ? AND type = 'MetareviewResponseMap'", participant.id])
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            allresponses = Response.find(:all, :conditions => ["map_id = ?", eachresponsemap.id])
            if !(allresponses.size > 0)#meaning the reviewer has not submitted a response for that map_id
              email_remind(fullname, email, assign_name, due_date, assign_type)
            #else
              #puts "~~~~~~~~~~~~~metareviewer #{fullname} has submitted a response"            
            end
        end
      end
    end #end of the for loop
  end

  def email_remind(fullname, email, assign_name, due_date, assign_type)
      #puts "~~~~~~~~~~~~~inside email reminder"
      due_date_string = due_date.due_at.to_s
      subject = "Message regarding #{assign_type} for #{assign_name}"
      puts "#{subject}\n"
      if(assign_type == "submission")
        body = "Hi #{fullname}, this is a reminder to complete #{assign_type} for #{assign_name}. "
        body = body + "Deadline is #{due_date_string}." 
        #puts "~~~~~~~~Message Body: #{body}\n"
      elsif(assign_type == "review")
        body = "Hi #{fullname}, this is a reminder to complete review of the latest resubmission of author in #{assign_type} for #{assign_name}. "
        body = body + "Deadline is #{due_date_string}." 
        #puts "~~~~~~~~Message Body: #{body}\n"
      elsif(assign_type == "metareview")
        body = "Hi #{fullname}, this is a reminder to complete metareview of assignment #{assign_type} for #{assign_name}. "
        body = body + "Deadline is #{due_date_string}." 
        #puts "~~~~~~~~Message Body: #{body}\n"
      end
      #if(next_due_date != nil)
       # next_due_date_string = next_due_date.due_at.to_s
       # body = body + "\n\rDeadline for #{next_assign_type} is #{next_due_date_string}.\n"
      #end
    
      Mailer.deliver_message(
        {:recipients => email,
         :subject => subject,
         :body => body
        })        
  end
  
  def email_start(fullname, email, assign_name)      
      subject = "Message regarding new assignment"
      body = "Hi #{fullname}, #{assign_name} has just been created."    
    
      Mailer.deliver_message(
        {:recipients => email,
         :subject => subject,
         :body => body
        })        
  end
  
end #end of class