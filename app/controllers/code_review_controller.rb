class CodeReviewController < ApplicationController
  require 'cgi'
  before_filter :authorize
  
  def create
    @participant = AssignmentParticipant.find(params[:participant_id])
    @code_review = CodeReview.new(params[:code_review])
    @code_review.files_uploaded = 0
    @code_review.save
    @participant.code_review = @code_review
    @participant.save
    
    redirect_to :back
  end
  
  def update
    @code_review = CodeReview.find(params[:code_review][:id])
    @code_review.update_attributes(params[:code_review])
    
    redirect_to :back
  end
  
  def download_file
    @file_to_download = ReviewFile.find(params[:id])
    @assignment = @file_to_download.code_review.participants[0].parent_id
    
    send_file @file_to_download.file_path, :disposition => 'inline', :filename => @file_to_download.file_name
  end
  
  def review_file
    @file_to_review = ReviewFile.find(params[:id])
    @participant = @file_to_review.code_review.participants[0]
    @lines = Array.new
    @line_comment = {}
    
    if @file_to_review
      file = File.new(@file_to_review.file_path, "r")
      while(line = file.gets)
        @lines << CGI.escapeHTML(line).gsub(/\t/,"&nbsp;&nbsp;&nbsp;&nbsp;")
      end
      
      if (@file_to_review.review_comments) 
        for review_comment in @file_to_review.review_comments
          @line_comment[review_comment.line_number] = review_comment          
        end
      end
    end
    
    @comments = ReviewComment.count(:conditions => ['review_file_id = ? and severity = ?', params[:id], "Comment"])
    @minors = ReviewComment.count(:conditions => ['review_file_id = ? and severity = ?', params[:id], "Minor"])
    @severes = ReviewComment.count(:conditions => ['review_file_id = ? and severity = ?', params[:id], "Severe"])
    @fatals = ReviewComment.count(:conditions => ['review_file_id = ? and severity = ?', params[:id], "Fatal"])
    
  end
  
  def add_comment()
    file = ReviewFile.find(params[:id])
    line = params[:line].to_i
    if (file) 
      review_comment = ReviewComment.new
      review_comment.review_file = file
      review_comment.line_number = line
      review_comment.comment = params[:comment]
      review_comment.severity = params[:severity]
      review_comment.save
    end
    
    redirect_to :back
  end
  
  def get_review_info
    file_to_review = ReviewFile.find(params[:id])
    output_html = ""
    output_html << "<div style='margin: 5px; margin-left: 15px; background-color: #FFFFCC;'>"
    
    if file_to_review
      ct = ReviewComment.count(:conditions => ['review_file_id = ?', params[:id]])
      output_html << "<b>" + (file_to_review.file_comment ? file_to_review.file_comment.to_s : "N/A") + "</b><br>";
      output_html << "Total Comments : " + (ct.to_s) + "</b><br>";
      output_html << "Uploaded at : " + (file_to_review.created_at.to_s) + "</b><br>";
    else
      output_html << "&nbsp;&nbsp;No information about this file is found. Refresh page and try again!"
    end
    
    output_html << "</div>"  
    render :text=>output_html
  end
  
  def get_review_content
    @file_to_review = ReviewFile.find(params[:id])
    #Post.find(:all, :conditions => [ "replyto = ?", @post.id])
    line = params[:line]
    output_html = ""
    review_comments = ReviewComment.find(:all, 
      :conditions => ["review_file_id=? and line_number=?", params[:id], line])
    if (review_comments.length() == 0)
      output_html << "No comments for this line.<br />"
    else
      output_html << "<span><table border='0'>"
      for review_comment in review_comments
        output_html << "<tr><td width='70%'>"
        output_html << ((review_comment.comment) + "</td><td width='30%' valign='top'>|")
        output_html << (review_comment.severity + "</td>")
        output_html << "</ tr>"
      end
      output_html << "</table></span>"
    end
    action_url = "'/code_review/add_comment/" + (params[:id]) + "'"
    
    output_html << "<br /><br />"
    output_html << "<form method='post' action="
    output_html << action_url
    output_html << ">\n"
    output_html << "<input type='hidden' name='authenticity_token' value='#{form_authenticity_token}' />\n"
    output_html << "<input type='hidden' name='line' value='" + line +  "' />\n";
    output_html << "<textarea rows='2' cols='60' name='comment'></textarea>\n<br />";
    output_html << " 
                    <select name='severity'>
                      <option value='Comment'>Comment</option>
                      <option value='Minor'>Minor</option>
                      <option value='Severe'>Severe</option>
                      <option value='Fatal'>Fatal</option>
                    </select>"

    output_html << "<input type='submit' value='Add Comment' />\n";
    output_html << "</form>\n"
    render :text=>output_html
  end
  
  def upload_file
    @code_review = CodeReview.find(params[:id])
    @assignment = Assignment.find_by_id(@code_review.participants[0].parent_id)
    
    directory_path = @assignment.directory_path
    uploaded_io = params[:datafile]
    success = false
    
    file_name = @code_review.id.to_s + "_" + @code_review.files_uploaded.to_s + ".dat" 
    path = File.join(directory_path, file_name)
    @msg = nil
    
    
    begin
      if not File.directory?(directory_path)
        Dir.mkdir(directory_path)
      end
      
      File.open(path, "wb") { |f|
        f.write(params[:datafile].read)    
      }
      success = true
    rescue
      @msg = "Error when uploading file. Contact Administrator."
      success = false
    end
    
    if success 
    
      @review_file = ReviewFile.new
      @review_file.file_comment = params[:comment][:txt]
      @review_file.file_path = path
      @review_file.file_name = uploaded_io.original_filename
      
      @review_file.accepted = false
      @review_file.code_review = @code_review
      if (@code_review.files_uploaded)
      	@code_review.files_uploaded = @code_review.files_uploaded + 1
      else 
      	@code_review.files_uploaded = 1 
      
      @code_review.save
      @review_file.save
      @msg = "File Uploaded Successfully."
    end
    redirect_to :back
  end
  
  private  
  def format_line(str)
    str.gsub(/\t/, "&nbsp;")
    str.gsub(/</, "&lt;")
    str.gsub(/>/, "&rt;")
    str.gsub(/\&/, "&amps;")
    
    str
  end
  
end
