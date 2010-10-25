class SuggestionController < ApplicationController

def add_comment_email(title,comment,email)
   Mailer.deliver_message(
     { :recipients => email,
       :subject => "A comment has been made on your suggestion \"#{title}\"",
       :body => "The instructor says: \"#{comment}\""
       
     }
     
   ) 
end

def send_status_update(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       :subject => "The status has changed on your suggestion \"#{title}\" ",
       :body => "Your suggestion is: \"#{status}\" " 
     }     
   )
end

 def send_back_update_instructor(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       
       :subject => "Your Suggestion #{title} has been edited and sent to you. ",
  
       :body => "Your suggestion is: \"#{status}\". Please log into Expertixa to check the changes made.. This topic can be edited further and sent back to the instructor for approval "
       
     }
     
   )
end

def send_back_update_student(title, status, email)
 Mailer.deliver_message(
     { :recipients => email,
       
       :subject => "The Suggestion #{title} has been edited by the student and sent to you. ",
 
       :body => " Please log into Expertiza and check the changes made"
       
     }
     
   )
end
 



  def add_comment
    @suggestioncomment = SuggestionComment.new(params[:suggestion_comment])
    @suggestioncomment.suggestion_id=params[:id]
    @suggestioncomment.commenter= session[:user].name
    if  @suggestioncomment.save
      @temp = AuditTrial.new
      @temp.suggestion_id = @suggestioncomment.suggestion_id
      @temp.unityID = @suggestioncomment.commenter
      @temp.title = nil
      @temp.description = @suggestioncomment.comments
      @temp.status = "comment"
      @temp.is_comment = 1
      @temp.save
      @suggestion=Suggestion.find(@temp.suggestion_id)
      if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
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
  
  def list

    
    if( params[:sortsuggestor].nil? && params[:sortstatus].nil?)
    if (params[:sortorder].nil? || params[:sortvar].nil?)
    @suggestions = Suggestion.find_all_by_assignment_id(params[:id])
    @assignment = Assignment.find(params[:id])
    @user_suggestion = Suggestion.all
    @user_unityID = Array.new
    @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
 @user_unityID.each do |f|
    if (f == "" || f.nil?)
      f.replace ("Anonymous")
  end
  end
  
    else
   
    @suggestions = Suggestion.find_all_by_assignment_id(params[:id],:order => "#{params[:sortvar]} #{params[:sortorder]}")
     @assignment = Assignment.find(params[:id])
      @user_suggestion = Suggestion.all
      @user_unityID = Array.new
        @user_suggestion.each do |f|
      @user_unityID << f.unityID
      end
   @user_unityID.uniq!
   @user_unityID.each do |f|
    if (f == "" || f.nil?)
      f.replace ("Anonymous")
  end
  end
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
   @user_unityID.each do |f|
    if (f == "" || f.nil?)
      f.replace ("Anonymous")
  end
end
else
  if (params[:sortstatus] == '') #sort only by suggestor only
    
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
   @user_unityID.each do |f|
    if (f == "" || f.nil?)
      f.replace ("Anonymous")
  end
end
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
   @user_unityID.each do |f|
    if (f == "" || f.nil?)
      f.replace ("Anonymous")
  end
end
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
      @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      if !(@suggestion.unityID == "")
      @temp.unityID = @suggestion.unityID
    else
      @temp.unityID = "anonymous"
      end
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
      render :action => 'confirm_save'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @suggestion = Suggestion.find(params[:id])
    
  end
  
  def update
    @suggestion = Suggestion.find(params[:id])
    for i in 1..100
    puts params[:description]
    end
    if @suggestion.update_attributes(params[:suggestion])
      @suggestion = Suggestion.find(params[:id])
      
      flash[:notice] = 'Suggestion was successfully updated.'
      redirect_to :action => 'show', :id => @suggestion.id
    end
  end
  
  def back_send
    
    @suggestion = Suggestion.find(params[:id])
    @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      @temp.unityID = session[:user].name
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
    if ((session[:user].role_id) != 1)
      if !(session[:user].name == @suggestion.unityID)
     @suggestion.control=0
     @suggestion.save
      if !(@suggestion.unityID == "")
     @email = User.find_by_name(@suggestion.unityID)
    if (!(@email.email==""))
     send_back_update_instructor(@suggestion.title,@suggestion.status,@email.email)
     end
     end
     flash[:notice] = 'Suggestion sent to student for revision!!!'
     else
      @suggestion.control=1
      @suggestion.save
      if !(@suggestion.unityID == "")
      @assignment = Assignment.find(@suggestion.assignment_id)
     @email = User.find(@assignment.instructor_id)
     if (!(@email.email==""))
     send_back_update_student(@suggestion.title,@suggestion.status,@email.email)
     end
     end
      flash[:notice] = 'Suggestion sent for approval!!!'
     end
    else
      @suggestion.control=1
      @suggestion.save
      if !(@suggestion.unityID == "")
      @assignment = Assignment.find(@suggestion.assignment_id)
     @email = User.find(@assignment.instructor_id)
     if (!(@email.email==""))
     send_back_update_student(@suggestion.title,@suggestion.status,@email.email)
     end
     end
      flash[:notice] = 'Suggestion sent for approval!!!'
    end
    #flash[:notice] = 'Suggestion sent!!!'
    redirect_to :action => 'show', :id => @suggestion.id
    
  end
  
  def view_suggestion
    @suggestions = Suggestion.find_all_by_unityID(session[:user].name)
    # @assignment = Assignment.find(params[:id])
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
      elsif !params[:defer_suggestion].nil?
      defer_suggestion
      elsif !params[:initiate_suggestion].nil?
      initiate_suggestion
    end
  end
  
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
       @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      @temp.unityID = session[:user].name
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
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
  
  def reject_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Rejected')
      flash[:notice] = 'Successfully rejected the suggestion'
       @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      @temp.unityID = session[:user].name
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
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
  
  def defer_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Deferred')
      flash[:notice] = 'Successfully deferred the suggestion'
       @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      @temp.unityID = session[:user].name
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
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
  
  def initiate_suggestion
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update_attribute('status', 'Initiated')
      flash[:notice] = 'Successfully Initiated the suggestion'
       @temp = AuditTrial.new
      @temp.suggestion_id = @suggestion.id
      @temp.unityID = session[:user].name
      @temp.title = @suggestion.title
      @temp.description = @suggestion.description
      @temp.status = @suggestion.status
      @temp.is_comment = 0
      @temp.save
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
  
  
def activity
@activity = AuditTrial.find_all_by_suggestion_id(params[:id], :order => "created_at")
@assignment_id = params[:assignment_id]
end



end
