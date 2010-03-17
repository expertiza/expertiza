include ActionController
include ActiveRecord

module SpawnHelper
  COMPLETE = "Complete"
  
  def background()               
    # thread for deadline emails
    spawn do        
      while true do        
        puts "~~~~~~~~~~Spawn Running, time.now is #{Time.now}\n"

        # find all assignments in database                
        allAssign = Assignment.find(:all)
        for assign in allAssign
         puts "assignment name #{assign.name}"
#          puts "~~~~~~~~~~Enter assignment, time.now is #{Time.now}\n and assign.created_at #{assign.created_at} and diff #{Time.now - assign.created_at}\n"
          
          if(Time.now - assign.created_at <= 5400)
            puts "time less than 5400, time.now is #{Time.now}\n"
            # get all participants
            allParts = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      

            for parts in allParts
                # get users full name
                fullname = User.find(parts.user_id).fullname    
                puts "~~~~~~~~~~Participant name: #{fullname}\n"
                
                # get users email address
                email    = User.find(parts.user_id).email      
                puts "~~~~~~~~~~Email: #{email}\n"
                
                # get name of assignment
                assign_name = assign.name
                puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                
                
                email_start(fullname, email, assign_name)
            end              
          else
            puts "time greater than 5400, time.now is #{Time.now}\n"
         end

          # get due date
          puts "Before get_current_due_date()\n"
          due_date = assign.find_current_stage()#get_current_due_date()
          #puts "~~~~~~~~~~Assignment: #{assign.name}, Due date: #{due_date.due_at}, Time now: #{Time.now}\n"
          #puts "~~~~~~~~~~Current Stage: #{DeadlineType.find(due_date.deadline_type_id).name}\n"
          
          if(due_date != COMPLETE and due_date != nil and due_date.flag != true)
            puts "due date isn't complete and flag isn't set"
            if(due_date.due_at - Time.now <= due_date.threshold * 3600)          
             puts "~~~~~~~~~~Enter < 600, #{due_date.due_at - Time.now}\n"
                           
              # get all participants
              allParts = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
              puts "~~~~~~~~~~All participants:\n"
              for parts in allParts
                # get users full name
                fullname = User.find(parts.user_id).fullname    
                puts "~~~~~~~~~~Participant name: #{fullname}\n"
                
                # get users email address
                email    = User.find(parts.user_id).email      
                puts "~~~~~~~~~~Email: #{email}\n"
                
                # get name of assignment
                assign_name = assign.name        
                puts "~~~~~~~~~~Assignment name: #{assign_name}\n"
                                
                # get assignment stage
                assign_type = DeadlineType.find(due_date.deadline_type_id).name
                puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"
                
                # get next due date if there is one
                #^^^^^^^^^^^^^^^^^^^added by Lakshmi- moved it from assignment.rb's find_next_stage() method
                due_dates = DueDate.find(:all, 
                 :conditions => ["assignment_id = ?", assign.id],
                 :order => "due_at DESC")
                 puts "!!!!number of due dates is #{due_dates.size}\n"
                if due_dates != nil and due_dates.size > 0
                  if Time.now > due_dates[0].due_at
                    next_due_date = COMPLETE
                  else
                    puts "in the else block\n"
                    i = 0
                    for due_date in due_dates
                      puts "looking at "
                      if Time.now < due_date.due_at and
                         (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
                         if (i > 0)
                           next_due_date = due_dates[i-1]
                           break
                         else
                           next_due_date = nil
                           break
                         end
                      end
                      i = i + 1
                    end #end of 'for' condition
                    next_due_date = nil
                  end #end of if condition
                else
                  next_due_date = nil #end of if condition
                end
                #^^^^^^^^^^^^^^^^^^^added by lakshmi

                #next_due_date = assign.find_next_stage()#get_next_due_date()
                
                if(next_due_date != nil)
                  puts "~~~~~~~~~~Next due date: #{next_due_date.due_at}\n"
                  next_assign_type = DeadlineType.find(next_due_date.deadline_type_id).name
                else
                  puts "~~~~~~~~~~~~~~Next due date is nil"
                end
                
                email_remind(fullname, email, assign_name, due_date, assign_type, next_due_date, next_assign_type)
                due_date.flag = true #setting the flag after the mail has been sent! #.setFlag()
                due_date.save 
                puts "flag set and saved"
              end #end of 'for' loop
              
            end # end of 'if' condition
          end # end of 'if' condition
        end #end of 'for' loop       
        puts "~~~~~~~~~~END"
        sleep 3600
      end #end of 'while' loop
    end #end of spawn

=begin
    # thread for send start notification
    spawn(:nice => 7) do
      sleep 15
      while true do
        allAssign = Assignment.find(:all)
        for assign in allAssign
          #puts "~~~~~~~~~~Enter assignment\n"
          if(Time.now - assign.created_at <= 3600)
            # get all participants
            allParts = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      

            for parts in allParts
                # get users full name
                fullname = User.find(parts.user_id).fullname    
                
                # get users email address
                email    = User.find(parts.user_id).email      
                
                # get name of assignment
                assign_name = assign.name
                #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"
                                
                # get assignment stage
                due_date = assign.get_current_due_date()
                if due_date != COMPLETE
                  assign_type = DeadlineType.find(due_date.deadline_type_id).name
                else assign_type = COMPLETE
                end
                #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"
                
                email_start(fullname, email, assign_name, due_date, assign_type)
            end              
          end
        end
        sleep 3600
        #puts "~~~~~~~~~~END1"
      end
    end
=end
  end #end of ''for' loop'background' method

  def email_remind(fullname, email, assign_name, due_date, assign_type, next_due_date, next_assign_type)
      due_date_string = due_date.due_at.to_s
      subject = "Message regarding #{assign_type} for #{assign_name}"
      puts "#{subject}\n"
      body = "Hi #{fullname}, this is a reminder to complete #{assign_type} for #{assign_name}. "
      body = body + "Deadline is #{due_date_string}."      
      if(next_due_date != nil)
        next_due_date_string = next_due_date.due_at.to_s
        body = body + "\n\rDeadline for #{next_assign_type} is #{next_due_date_string}.\n"
      end
    
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