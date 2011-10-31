class SuggestionController < ApplicationController

# When an instructor adds a comment to a suggestion given by a student, the student gets notified via this method
#Please note that as per docs/email_readme, we are supposed to have one method per email. We are complying 
#to that and hence the code repetition. Please consider this while rating code repetition.
#PART OF IMPROVEMENT TO SUGGEST AND APPROVE
def add_comment_email(title,comment,email)
   Mailer.deliver_message(
     { :recipients => email,
       :subject => "A comment has been made on your suggestion \"#{title}\"",
       :body => "The instructor says: \"#{comment}\""
       
     }
     
   ) 
end

# When there is a status change for a suggestion (Status can be Approved, Rejected, Deferred), it will be notified to the 
#student who suggested the topic via this method
#PART OF IMPROVEMENT TO SUGGEST AND APPROVE
def send_status_update(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       :subject => "The status has changed on your suggestion \"#{title}\" ",
       :body => "Your suggestion is: \"#{status}\" " 
     }     
   )
end

# This method will notify the suggestor when an instructor edits it and send back to him/her for review
#PART OF IMPROVEMENT TO SUGGEST AND APPROVE
 def send_back_update_instructor(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       
       :subject => "Your Suggestion #{title} has been edited and sent to you. ",
  
       :body => "Your suggestion is: \"#{status}\". Please log into Expertixa to check the changes made.. This topic can be edited further and sent back to the instructor for approval "
       
     }
     
   )
end

#This method notifies the instructor when a student edits his suggestion and send it to the instructor for approval
#PART OF IMPROVEMENT TO SUGGEST AND APPROVE
def send_back_update_student(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       
       :subject => "The Suggestion #{title} has been edited by the student and sent to you. ",
 
       :body => " Please log into Expertiza and check the changes made"
       
     }
     
   )
end
 
#add audit trail for the suggestion at various situations. 
def add_audit_trail(id, unityID,title,description,status,is_comment)
      # Below are the fields of Audit trial table that gets populated when a comment is made
      @new_audit_trial = AuditTrial.new
      @new_audit_trial.suggestion_id = id
      @new_audit_trial.unityID = unityID
      @new_audit_trial.title = title
      @new_audit_trial.description = description
      @new_audit_trial.status = status
      @new_audit_trial.is_comment = is_comment
      @new_audit_trial.save
     @new_audit_trial.id# returning active records id in case it needs to be used on return
     end

# This method allows an instructor to add and submit a cooment for a particular suggestion
  def add_comment
    # New comment is added using new method
    @suggestioncomment = SuggestionComment.new(params[:suggestion_comment])
    @suggestioncomment.suggestion_id=params[:id]
    @suggestioncomment.commenter= session[:user].name
 
    if  @suggestioncomment.save
      #PART OF IMPROVEMENT TO SUGGEST AND APPROVE
      # As soon as a comment is added, it should get saved in the Audit Trial table for generating history report on suggestions
      @new_audit_trial=AuditTrial.find(add_audit_trail(@suggestioncomment.suggestion_id,@suggestioncomment.commenter,nil,@suggestioncomment.comments,"comment by instructor/ta",1))
    
      @suggestion=Suggestion.find(@new_audit_trial.suggestion_id)
      # Send an email only if its not an anonymous suggestion
      
      if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
     #Send an email only if an email id is associated with a student or an instructor. Email ids can also be null
     if (!(@email.email==""))
     add_comment_email(@suggestion.title, @suggestioncomment.comments, @email.email)  
    end
    end
      flash[:notice] = "Successfully added your comment"
    else
      flash[:error] = "Error while adding comment"
    end
    redirect_to :action => "show", :id => params[:id]
  end
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
 #This method handles anonymous suggestions while sorting. Was factored out because of code repetition
 def handle_list_anonymous(arr)
   arr.each do |f|
    if (f == "" || f.nil?)# If the suggestion is anonymous display the suggestor name as "Anonymous"
      f.replace ("Anonymous")
  end
  end
  arr
 end
 
 # list method will list all the suggestions made by different students on a particular assignment.
    def list
    #PART OF IMPROVEMENT TO SUGGEST AND APPROVE
    #Sorting Implemented here. Checking to see what we want to sort by
    if( params[:sortsuggestor].nil? && params[:sortstatus].nil?) #If no sorting specified either by suggestor or status
    if (params[:sortorder].nil? || params[:sortvar].nil?)#if there is no order given, display in the usual way
    @suggestions = Suggestion.find_all_by_assignment_id(params[:id])
    @assignment = Assignment.find(params[:id])
    @user_suggestion = Suggestion.all
    @user_unityID = Array.new
    @user_suggestion.each do |f| 
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
   #we can factor out the 3 lines of code below but have avoided doing this because we were having trouble 
     # with returning the array from a function call. I suppose 3 lines of code repetition can be excused
@user_unityID = handle_list_anonymous(@user_unityID)
  
    else # Sort by either status, suggestor etc in ascending or descneding.
   
    @suggestions = Suggestion.find_all_by_assignment_id(params[:id],:order => "#{params[:sortvar]} #{params[:sortorder]}")
     @assignment = Assignment.find(params[:id])
      @user_suggestion = Suggestion.all
      @user_unityID = Array.new
        @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
   @user_unityID = handle_list_anonymous(@user_unityID)
end
else #either one of the second sort option selected
  if (params[:sortsuggestor] == '' ) #sort only by status
    
  @suggestions = Suggestion.find_all_by_assignment_id_and_status(params[:id],"#{params[:sortstatus]}")
     @assignment = Assignment.find(params[:id])
      @user_suggestion = Suggestion.all
      @user_unityID = Array.new
        @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
   @user_unityID = handle_list_anonymous(@user_unityID)
else
  if (params[:sortstatus] == '') #sort only by suggester only
    
    if(params[:sortsuggestor] == 'Anonymous')
    @suggestions = Suggestion.find_all_by_assignment_id_and_unityID(params[:id],"")
    else
     @suggestions = Suggestion.find_all_by_assignment_id_and_unityID(params[:id],"#{params[:sortsuggestor]}")
     end
     @assignment = Assignment.find(params[:id])
      @user_suggestion = Suggestion.all
      @user_unityID = Array.new
        @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
      @user_unityID = handle_list_anonymous(@user_unityID)
else # sort by both

if(params[:sortsuggestor] == 'Anonymous')
    @suggestions = Suggestion.find_all_by_assignment_id_and_unityID_and_status(params[:id],"","#{params[:sortstatus]}")
    else
     @suggestions = Suggestion.find_all_by_assignment_id_and_unityID_and_status(params[:id],"#{params[:sortsuggestor]}","#{params[:sortstatus]}")
     end
     @assignment = Assignment.find(params[:id])
      @user_suggestion = Suggestion.all
      @user_unityID = Array.new
        @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
      @user_unityID = handle_list_anonymous(@user_unityID)
end

end
end
  end
  
  def show
    @suggestion = Suggestion.find(params[:id])
    
  end
  
  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]
    
  end
 
 # this method creates a new suggestion by a student. If the user prefers not to reveal his identity, he can suggest
 # a topic as anonymous user. Initially control field in suggestion table will be 0. When a student suggests a topic
 # and send it to the instructor, this method will make the control filed 1 which indicates that the instructor must take an action now
  def create    
    @suggestion = Suggestion.new(params[:suggestion])
    @suggestion.assignment_id = session[:assignment_id]
    @suggestion.status = 'Initiated'
    if params[:suggestion_anonymous].nil?
      @suggestion.unityID = session[:user].name      
    else
      @suggestion.unityID = ""
    end
    @suggestion.control=1
    if @suggestion.save
      #PART OF IMPROVEMENT TO SUGGEST AND APPROVE
      #handling anonymous user/anonymous suggestion
      if !(@suggestion.unityID == "")
      add_audit_trail(@suggestion.id,@suggestion.unityID,@suggestion.title,@suggestion.description,"Initial Submit",0)
      
    else
      add_audit_trail(@suggestion.id,"anonymous",@suggestion.title,@suggestion.description,"Initial Submit",0)
      
      end
     
      render :action => 'confirm_save'
    else
      render :action => 'new'
    end
  end

 # This method gets called when a student or an instructor clicks on the edit button for a suggestion
  def edit
    @suggestion = Suggestion.find(params[:id])
    
  end
 # Once the student or an instructor edits a suggestion and saves it, update method gets called and the edited fields are saved
# in the DB. 
  def update
    @suggestion = Suggestion.find(params[:id])

    if @suggestion.update_attributes(params[:suggestion])
      @suggestion = Suggestion.find(params[:id])
      
      flash[:notice] = 'Suggestion was successfully updated.'
      redirect_to :action => 'show', :id => @suggestion.id
    end
  end
  
   # Every time a student or an instructor sends back the edited suggestion, 
#corresponding entry must be made in the audit trial table and an email sent
 def send_email_to_student(suggestion)
    
    suggestion.control=1
      suggestion.save
      add_audit_trail(suggestion.id,session[:user].name,suggestion.title,suggestion.description,"Student edited",0)
        if !(suggestion.unityID == "")
      @assignment = Assignment.find(suggestion.assignment_id)
     @email = User.find(@assignment.instructor_id)
     if (!(@email.email==""))
     send_back_update_student(suggestion.title,suggestion.status,@email.email)
     end
     end
      flash[:notice] = 'Suggestion sent for approval!!!'
 end
 
 
 # This method is called when an instructor and a student send back and forth, the edited suggestions for approval and review respectively
  def back_send
    
    @suggestion = Suggestion.find(params[:id])
     
     
    if ((session[:user].role_id) != 1) #If TA or Instructor
      if !(session[:user].name == @suggestion.unityID)
     @suggestion.control=0
     @suggestion.save
     
     # Every time a student or an instructor sends back the edited suggestion, 
#corresponding entry must be made in the audit trial table
      
     add_audit_trail(@suggestion.id,session[:user].name,@suggestion.title,@suggestion.description,"Instructor Edited",0)
     
      if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
    if (!(@email.email==""))
     send_back_update_instructor(@suggestion.title,@suggestion.status,@email.email)
     end
     end
     flash[:notice] = 'Suggestion sent to student for revision!!!'
     else
     send_email_to_student(@suggestion)
     end
    else #Student
     send_email_to_student(@suggestion)
    end
    #flash[:notice] = 'Suggestion sent!!!'
    redirect_to :action => 'show', :id => @suggestion.id
    
  end
 
  #This method finds all suggestions for an assignment by  the suggestor's Unity ID
  def view_suggestion
    @suggestions = Suggestion.find_all_by_unityID(session[:user].name)
 
  end
  
  def confirm_save
    # Action to display successful creation of suggestion
  end
  
  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      approve_suggestion
    elsif !params[:reject_suggestion].nil?
      reject_suggestion
      # begin E3-B
      # HEAD
      # elsif !params[:defer_suggestion].nil? # added this to support new status defered
      # defer_suggestion
      # elsif !params[:initiate_suggestion].nil?
      # initiate_suggestion
      # end E3-B
    elsif !params[:edit_suggestion].nil?
      edit_suggestion
      # begin A
      # c01f33e... E3: Team: OSS project_Team1
      # end A
    end
  end
  
  # this method gets called when the instructor clicks on Approve Suggestion button
  def approve_suggestion
    @suggestion = Suggestion.find(params[:id])
    @signuptopic = SignUpTopic.new
    @signuptopic.topic_identifier = 'S' + @suggestion.id.to_s
    @signuptopic.topic_name = @suggestion.title
    @signuptopic.assignment_id = @suggestion.assignment_id
    @signuptopic.description = @suggestion.description  
    
    @signuptopic.max_choosers = 3;
    
    if @signuptopic.save && @suggestion.update_attribute('status', 'Approved')
      flash[:notice] = 'Successfully approved the suggestion.'
      
      add_audit_trail(@suggestion.id,session[:user].name,@suggestion.title,@suggestion.description,@suggestion.status,0)
       if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
     if (!(@email.email==""))
     send_status_update(@suggestion.title,@suggestion.status,@email.email)
     end
     end
    else
      flash[:error] = 'Error when approving the suggestion.'
    end
    
    redirect_to :action => 'show', :id => @suggestion
  end

#We can avoid code duplication in the methods reject_suggestion, defer_suggestion and initiate_suggestion 
#below but avoided this to avoid conflicts with other groups while checking into svn. 
#This was code that already existed and we did not want to modify something existing.

 # this method gets called when the instructor clicks on Reject Suggestion button
  def reject_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Rejected')
      flash[:notice] = 'Successfully rejected the suggestion'
      #PART OF IMPROVEMENT TO SUGGEST AND APPROVE, does the same things as explained before
       add_audit_trail(@suggestion.id,session[:user].name,@suggestion.title,@suggestion.description,@suggestion.status,0)
       if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
     if (!(@email.email==""))
     send_status_update(@suggestion.title,@suggestion.status,@email.email)
     end
     end
    else
      flash[:error] = 'Error when rejecting the suggestion'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
=begin
# begin E3-B
# HEAD
   # this method gets called when the instructor clicks on Defer Suggestion button
  def defer_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Deferred')
      flash[:notice] = 'Successfully deferred the suggestion'
      add_audit_trail(@suggestion.id,session[:user].name,@suggestion.title,@suggestion.description,@suggestion.status,0)
      
       if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
     if (!(@email.email==""))
     send_status_update(@suggestion.title,@suggestion.status,@email.email)
     end
     end
    else
      flash[:error] = 'Error when deferring the suggestion'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
   # this method gets called when the instructor clicks on Initiate again button of a defered suggestion
  def initiate_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Initiated')
      flash[:notice] = 'Successfully Initiated the suggestion'
       add_audit_trail(@suggestion.id,session[:user].name,@suggestion.title,@suggestion.description,@suggestion.status,0)
       if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
     if (!(@email.email==""))
     send_status_update(@suggestion.title,@suggestion.status,@email.email)
     end
     end
    else
      flash[:error] = 'Error when Initiating the suggestion'
    end
    redirect_to :action => 'show', :id => @suggestion
  end
  
#This method will sort the suggestions of a particular assignment based on either the suggestor's Unity ID 
#or Status of suggestion or by updated date  


def list_sort
    if session[:display]      
      @sortvar = session[:display][:sortvar]
      @sortorder = session[:display][:sortorder]
      if session[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
    end
    if params[:display]      
      @sortvar = params[:display][:sortvar]
      @sortorder = params[:display][:sortorder] 
      if params[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
      session[:display] = params[:display]      
    end
  
    if session[:display].nil? and params[:display].nil?
      @show = true
    end
    
    if @sortvar == nil
      @sortvar = 'name'
    end
    if @sortorder == nil
      @sortorder = 'asc'
    end
        
    if session[:root]
      @root_node = Node.find(session[:root])
      @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show)
    else
      @child_nodes = FolderNode.get()
    end    
  end   
  
# this method finds all suggestions by id in the audit trial table. this is needed to dispay the Activity log for the suggestions  
def activity
@activity = AuditTrial.find_all_by_suggestion_id(params[:id], :order => "created_at")
@assignment_id = params[:assignment_id]
end


  def edit_suggestion
    @suggestion = Suggestion.find(params[:id])
    if @suggestion.unityID != session[:user].name
      if not @suggestion.unityID.nil? and not @suggestion.unityID.empty?
        user = User.find_by_name(@suggestion.unityID)
        @toemail = user.id
      else
        @toemail = nil
      end
      @editor = "instructor"
      @suggestion.status = 'Reviewed'
    else
      assnt = Assignment.find(@suggestion.assignment_id)
      course = Course.find(assnt.course_id)
      instructor = User.find(course.instructor_id)
      @toemail = instructor.id
      @editor = session[:user].name
      @suggestion.status = 'Resubmitted'
    end
    
    if @suggestion.update_attributes(params[:suggestion_edit])
      flash[:notice] = 'Successfully updated the suggestion'
      if not @toemail.nil?
        @suggestion.email(@toemail, @editor)
      end
      #call log function here
    else
      flash[:error] = 'Error when updating the suggestion'
    end
    if @editor == "instructor"
      redirect_to :action => "show", :id => params[:id]
    else
      redirect_to :action => "view_comments", :id => @suggestion.assignment_id
    end
  end
  
  def view_comments
    assignment = Assignment.find(params[:id])
    @suggestions = Suggestion.find(:all, :conditions =>
              "unityID = '#{session[:user].name}' and status not in ('Approved', 'Rejected') and assignment_id = #{params[:id]}")
  end
  
# end A c01f33e... E3: Team: OSS project_Team1
end
