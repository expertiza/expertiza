class CodeReviewFilesController < ApplicationController

  #used to show all the files for a particular user and assignment
  def show_code_review_file
    @code_review_file = CodeReviewFile.find(params[:id])
    @participant = Participant.find(@code_review_file.participantid)

    #if the user is not a student, show all comments, otherwise show comments for entire document for
    #author and show comments for each reviewer ...
    if session[:user].role_id != 1 #if non-student
      @comments = CodeReviewComment.find_all_by_codefileid(@code_review_file.id)
    else
      if(session[:user].id != @participant.user_id)
        @comments = CodeReviewComment.find_all_by_codefileid_and_participantid(@code_review_file.id, session[:user].id)
      else
        @comments = CodeReviewComment.find_all_by_codefileid(@code_review_file.id)
      end
    end
  end

  #uploading a new file to be added to the assignment
  def create_code_review_file
    #get the file
  	file = params[:code_review_file]
    #get the name ...
    name = file['name']
    
    #if the file is under a certain amount of characters, ruby will treat is like a string
    if file['contents'].class == String
      contents = file['contents']
      name = "uploaded file" unless name #try to help if the file was not named
    #otherwise, it is a file object....
    else
     contents = file['contents'].read 
     name = file['contents'].original_filename unless name #try to help if the file was not named
    end
    
    #create a new file to be inserted in the db
    @code_review_file = CodeReviewFile.new(params[:code_review_file])
    @code_review_file.contents = contents
    @code_review_file.name = name

    #check if things went well ... 
    respond_to do |format|
      if @code_review_file.save
        flash[:notice] = 'CodeReviewFile was successfully created.'
        format.html { redirect_to(:controller => 'submitted_content', :action => 'edit', :id => @code_review_file.participantid) }
        format.xml  { render :xml => @code_review_file, :status => :created, :location => @code_review_file }
      else
        flash[:notice] = 'CodeReviewFile was not successfully created.'
        format.html { redirect_to(:controller => 'submitted_content', :action => 'edit', :id => @code_review_file.participantid) }
        format.xml  { render :xml => @code_review_file.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  #not implemented yet .... maybe used to update the name of the file?
  #also maybe update the contents of the reviewed file...  but this would also remove any existing comments!?!?
  def update_code_review_file
  end

  #when author wants to delete a file they uploaded.
  def delete_code_review_file
    code_review_file = CodeReviewFile.find(params[:id])
    participantid = code_review_file.participantid
    #remove all associated comments.
    if code_review_file
        comments = CodeReviewComment.find_by_sql("select * from code_review_comments where codefileid = " + params[:id])
        comments.each do |comment|
          comment.destroy
        end
        #destroy the file....
        code_review_file.destroy
    end
    #redirect back to same page....
    redirect_to(:controller => 'submitted_content', :action => 'edit', :id => participantid)
  end

  #not implemented yet
  def rename_code_review_file
  end
  
  #creating a new file comment...
  def create_code_review_file_comment
    @comment = CodeReviewComment.new
    @comment.r_begins = params[:startentry]
    @comment.r_end = params[:endentry]
    @comment.r_scroll = params[:topentry]
    @comment.body = params[:commenttext]
    @comment.participantid = params[:participantid]
    @comment.codefileid = params[:codefileid]
    
    #how to get the next number to show ...
    if session[:user].role_id != 1 #if non-student
      @commentnumber = CodeReviewComment.find_all_by_codefileid(params[:codefileid]).length + 1
    else
      @commentnumber = CodeReviewComment.find_all_by_codefileid_and_participantid(params[:codefileid], params[:participantid]).length + 1
    end

    #ajax magic ... poof !
    if(@comment.save)    
      @rtext = "<div id=\"commententry\" onClick=\"hiClickNumber(" + params[:topentry] + ", " + params[:startentry] + ", " + params[:endentry] + ")\">";
      @rtext += "<span id=\"fakelink\">Comment " + @commentnumber.to_s + "</span>"
      if(session[:user].id == @comment.participantid)
         @rtext += "<span id=\"fakelink\" onClick=\"deleteComment(" + @comment.id.to_s + ")\">(delete)</span>"
      end
      @rtext += "<br/>"
      @rtext += params[:commenttext]
      @rtext += "</div>"
      render :text => @rtext
    end
    #render :text => params[:topentry] + params[:startentry] + params[:endentry] + params[:commenttext]
  end
  
  #not implemented yet
  def update_code_review_file_comment
  end

  #delete a comment 
  def delete_code_review_file_comment
    @comment = CodeReviewComment.find_by_id(params[:id])
    @codefileid = @comment.codefileid
    if @comment
      @comment.delete
    end
    
    redirect_to(:action => 'show_code_review_file', :id => @codefileid)
  end
end
