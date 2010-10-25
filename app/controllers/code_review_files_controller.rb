class CodeReviewFilesController < ApplicationController

  def show_code_review_file
    @code_review_file = CodeReviewFile.find(params[:id])
    @participant = Participant.find(@code_review_file.participantid)
	@currentparticipant = 
	if(session[:user].id != @participant.user_id)
      @comments = CodeReviewComment.find_all_by_codefileid_and_participantid(@code_review_file.id, session[:user].id)
	else
	  @comments = CodeReviewComment.find_all_by_codefileid(@code_review_file.id)
	end
  end

  def create_code_review_file
  	file = params[:code_review_file]
    name = file['name']
    
    if file['contents'].class == String
      contents = file['contents']
      name = "uploaded file" unless name
    else
     contents = file['contents'].read 
     name = file['contents'].original_filename unless name
    end
    
    @code_review_file = CodeReviewFile.new(params[:code_review_file])
    @code_review_file.contents = contents
    @code_review_file.name = name
    respond_to do |format|
      if @code_review_file.save
        flash[:notice] = 'CodeReviewFile was successfully created.'
        format.html { redirect_to(:controller => 'student_task', :action => 'list') }
        format.xml  { render :xml => @code_review_file, :status => :created, :location => @code_review_file }
      else
        flash[:notice] = 'CodeReviewFile was not successfully created.'
        format.html { redirect_to(:controller => 'student_task', :action => 'list') }
        format.xml  { render :xml => @code_review_file.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update_code_review_file
  end
  def delete_code_review_file
  end
  def rename_code_review_file
  end
  
  def create_code_review_file_comment
    @comment = CodeReviewComment.new
    @comment.r_begins = params[:startentry]
    @comment.r_end = params[:endentry]
    @comment.r_scroll = params[:topentry]
    @comment.body = params[:commenttext]
    @comment.participantid = params[:participantid]
    @comment.codefileid = params[:codefileid]
    
    if(@comment.save)    
      @rtext = "<div id=\"commententry\" onClick=\"hiClickNumber(" + params[:topentry] + ", " + params[:startentry] + ", " + params[:endentry] + ")\">";
      @rtext += "<span id=\"fakelink\">Comment " + (CodeReviewComment.find_all_by_codefileid_and_participantid(params[:codefileid], params[:participantid]).length).to_s + "</span><br/>"
      @rtext += params[:commenttext]
      @rtext += "</div>"
      render :text => @rtext
    end
    #render :text => params[:topentry] + params[:startentry] + params[:endentry] + params[:commenttext]
  end
  
  def update_code_review_file_comment
  end
  def delete_code_review_file_comment
  end
end
