class ReviewFilesController < ApplicationController
  #rescue_from Exception, :with => :render_error_page
  helper :diff

  # This method accepts the review_file from the view-form and calculates/creates
  # appropriate directories to store the file. The following two parameters need
  # to be passed in from the view:
  # params[:participant_id], params[:uploaded_review_file]
  def submit_review_file
    participant = AssignmentParticipant.find(params[:participant_id])
    return unless current_user_id?(participant.user_id)

    file = params[:uploaded_review_file]
    new_version_number = ReviewFile.get_max_version_num(participant) + 1

    # Calculate the directory for unzipping files
    participant.set_student_directory_num
    version_dir = ReviewFilesHelper::get_version_directory(participant,
                                                           new_version_number)
    FileUtils.mkdir_p(version_dir) unless File.exists? version_dir

    filename_only = ReviewFilesHelper::get_safe_filename(
      file.original_filename.to_s)
    full_filename = version_dir + filename_only



    # Copy file into version_dir
    File.open(full_filename, "wb") {
      |f| f.write(file.read) }


    #--------------New Code----------------#
    #--------------If submitted file is a zip file, then unzip it----------------#

    # If Zip file, then Unzip submission
    if ReviewFilesHelper::get_file_type(filename_only) == "zip"
      SubmittedContentHelper::unzip_file(full_filename, version_dir, true)
    end
    # For all files in the version_dir, add entries in the review_file table
    participant.get_files(version_dir).each do |each_file|
      @review_file = ReviewFile.new
      @review_file.filepath               = each_file.to_s
      @review_file.version_number         = new_version_number
      @review_file.author_participant_id  = participant.id
      @success = @review_file.save ? true : false
    end

    respond_to do |format|
      if @success
        format.html { redirect_to :action => 'show_all_submitted_files',
                      :participant_id => participant.id and return}
        format.xml  { render :xml => @review_file, :status => :created,
                      :location => @review_file and return}
      else
        flash[:error] = "Code Review File was <b>not</b> successfully" +
          "uploaded. Please Re-Submit."
        format.html { redirect_to :action => 'show_all_submitted_files',
                      :participant_id => participant.id and return}
        format.xml  { render :xml => @review_file.errors,
                      :status => :unprocessable_entity and return}
      end
    end

  end


  # This method computes the list of all files submitted by the participant along
  # with all the versions the files are present in. This method needs the following
  # two parameters:
  # params[:participant_id], Needs params[:stage]
  def show_all_submitted_files
    @participant = AssignmentParticipant.find(params[:participant_id])
    @stage = params[:stage]

    # Find all files over all versions submitted by the team
    all_review_files = []

    if @participant.assignment.team_assignment
      @participant.team.get_participants.each_with_index { |member,index|
        all_review_files += ReviewFile.where(author_participant_id: member.id)

      }
    else
      all_review_files = ReviewFile.where(author_participant_id: @participant.id)
    end

    auth=Hash.new
    # For each file in the above list find out the various versions in which it occurs
    @file_version_map = Hash.new
    all_review_files.each_with_index do |each_file,index|
      @file_version_map[File.basename(each_file.filepath)] = Array.new unless
      @file_version_map[File.basename(each_file.filepath)]
      @file_version_map[File.basename(each_file.filepath)] << each_file.version_number


      auth[File.basename(each_file.filepath)] = Hash.new unless
      auth[File.basename(each_file.filepath)]
      auth[File.basename(each_file.filepath)][each_file.version_number] = each_file.author_participant_id
    end



    # For each file in the above map create a new map, to store the
    #   filename -> review_file_id mapping.
    @file_id_map = Hash.new
    @latest_version_number = 0
    @file_version_map.each do |base_filename, versions|

      code_review_dir = ReviewFilesHelper::get_code_review_file_dir(AssignmentParticipant.find(auth[base_filename][versions.sort.last]))
      file_path = ReviewFile.get_file(code_review_dir, versions.sort.last,base_filename)
      all_review_files.each do |file|
        @file_id_map[base_filename] = file.id
      end

      @file_version_map[base_filename] =  versions.sort
      @latest_version_number = (@file_version_map[base_filename][-1] >
                                @latest_version_number) ? @file_version_map[base_filename][-1] :
      @latest_version_number
  end

end

=begin
   # This method is used to generate the view where the particular code file is
   # viewed 'individually' (not diff).
   # params[:review_file_id] - Id of the review_file whose source is to be shown
   # params[:participant_id]
   # params[:versions] an array (in asc order) of all versions of the review file
   #                   contained in params[:review_file_id]
   def show_code_file
     @participant = AssignmentParticipant.find(params[:participant_id])

     @current_review_file = ReviewFile.find(params[:review_file_id])
     review_file=nil

     newer_version_comments = ReviewComment.where(review_file_id: @current_review_file.id)

     @version_fileId_map = Hash.new
     params[:versions].each do |each_version|

       get_files_with_the_current_version = ReviewFile.where(version_number: each_version)
       get_files_with_the_current_version.each {|file|
         if File.basename(file.filepath) == File.basename(@current_review_file.filepath)
           review_file = file.id
         end
       }


       @version_fileId_map[each_version] = review_file ? review_file: nil
     end

     file_contents = File.open(@current_review_file.filepath).readlines
     offset_array = [0]

     offset_array = ReviewFile.get_offset_array(file_contents)

     @shareObj = Hash.new()
     @shareObj['linearray2'] = file_contents
     @shareObj['offsetarray2'] = offset_array
     @highlight_cell_right_file=ReviewFile.highlightRightOffset(newer_version_comments,offset_array,file_contents)

   end
=end

# This method is used to generate the view where the particular code file is
# viewed 'individually' (not diff).
# params[:review_file_id] - Id of the review_file whose source is to be shown
# params[:participant_id]
# params[:versions] an array (in asc order) of all versions of the review file
#                   contained in params[:review_file_id]
def show_code_file
  @participant = AssignmentParticipant.find(params[:participant_id])
  @current_review_file = ReviewFile.find(params[:review_file_id])

  review_file=nil

  newer_version_comments = ReviewComment.where(review_file_id: @current_review_file.id)

  @version_fileId_map = Hash.new
  params[:versions].each do |each_version|

    get_files_with_the_current_version = ReviewFile.where(["version_number = :vid and author_participant_id = :pid", { vid: each_version, pid: @participant }])
    get_files_with_the_current_version.each {|file|
      if File.basename(file.filepath) == File.basename(@current_review_file.filepath)
        review_file = file.id
      end
    }

    @version_fileId_map[each_version] = review_file ? review_file: nil
  end

  file_contents = File.open(@current_review_file.filepath).readlines
  offset_array = [0]

  offset_array = ReviewFile.get_offset_array(file_contents)

  @shareObj = Hash.new()
  @shareObj['linearray2'] = file_contents
  @shareObj['offsetarray2'] = offset_array
  @highlight_cell_right_file=ReviewFile.highlightRightOffset(newer_version_comments,offset_array,file_contents)


end

# params[:participant_id]
# params[:versions] an array (in asc order) of all versions of the review file
# params[:diff_with_file_id] - Id of current file to be diffed with
# params[:current_version_id] the if of current version of file
def show_code_file_diff
  @participant = AssignmentParticipant.find(params[:participant_id])
  review_file=nil
  # Get the filepath of both the files.
  older_file = ReviewFile.find(params[:current_version_id])
  newer_file = ReviewFile.find(params[:diff_with_file_id])

  @current_review_file = older_file

  @version_fileId_map = Hash.new
  params[:versions].each do |each_version|
    get_files_with_the_current_version = ReviewFile.where(["version_number = :vid and author_participant_id = :pid", { vid: each_version, pid: @participant }])
    get_files_with_the_current_version.each {|file|
      if File.basename(file.filepath) == File.basename(@current_review_file.filepath)
        review_file = file.id
      end
    }
    @version_fileId_map[each_version] = review_file ? review_file : nil
  end

  # Swap them if older is more recent than newer
  files = Hash.new
  # Swap them if older is more recent than newer

  files = ReviewFile.swap_files(older_file, newer_file)

  processor = DiffHelper::Processor.new(files[:@older_file].filepath, files[:@newer_file].filepath)
  processor.process!

  @first_line_num = []
  @second_line_num = []
  @first_offset = []
  @second_offset = []
  first_count = 0
  second_count = 0
  @offsetswithcomments_file1 = []
  @offsetswithcomments_file2 = []

  @first_offset << 0
  @second_offset << 0

  for i in (0..processor.absolute_line_num)

    @first_offset = ReviewFile.get_first_offset(processor, i, @first_offset)

    @second_offset = ReviewFile.get_second_offset(processor, i, @second_offset)

    first_line_num = Hash.new
    first_line_num = ReviewFile.get_first_line_num(processor, i, first_count)

    @first_line_num << first_line_num[:@first_line_num]
    first_count = first_line_num[:first_count]

    second_line_num = Hash.new
    second_line_num = ReviewFile.get_second_line_num(processor, i,second_count)
    @second_line_num << second_line_num[:@second_line_num]
    second_count = second_line_num[:second_count]

    # Remove newlines at the end of this line of code
    processor = ReviewFile.get_first_file_array(processor, i)

    processor = ReviewFile.get_second_file_array(processor, i)


end

older_version_comments = ReviewComment.where(review_file_id: files[:@older_file].id)
newer_version_comments = ReviewComment.where(review_file_id: files[:@newer_file].id)

@shareObj = Hash.new()
@shareObj['linearray1'] = processor.first_file_array
@shareObj['linearray2'] = processor.second_file_array
@shareObj['comparator'] = processor.comparison_array
@shareObj['linenumarray1'] = @first_line_num
@shareObj['linenumarray2'] = @second_line_num
@shareObj['offsetarray1'] = @first_offset
@shareObj['offsetarray2'] = @second_offset
@file_on_left = files[:@older_file]
@file_on_right = files[:@newer_file]


# REFACTOR: Code Duplication removed
@highlight_cell_left_file=   ReviewFile.getHighlightCellLeft(older_version_comments,@first_offset,@first_line_num)

@highlight_cell_right_file=ReviewFile.getHighlightCellRight(newer_version_comments,@second_offset,@second_line_num)

  end



  def submit_comment
    @comment = ReviewComment.new
    @comment.review_file_id = params[:file_id]
    @comment.file_offset = params[:file_offset]
    @comment.last_line_number = params[:last_line]
    @comment.initial_line_number = params[:first_line]
    assignmentparticipant = AssignmentParticipant.find(params[:participant_id])

    current_participant = AssignmentParticipant.where(parent_id: assignmentparticipant[:parent_id], user_id: session[:user].id).first


    @comment.reviewer_participant_id = current_participant.id
    @comment.comment_content = params[:comment_content].gsub("\n", " ")
    @comment.save
  end

  # modified vandit.

  # Needs params[:file_id], params[:file_offset]

  # Needs params[:file_id], params[:file_offset]
  def get_comments

    comments_in_table = "<table width='100%' cellpadding='3' style='table-layout: fixed; word-wrap: break-word;'>"
    i=0
    authorflag = 0 # used to identify whether the reply to the comment button should be displayed

    newobj =  ReviewComment.where(review_file_id: params[:file_id]);
    ReviewComment.where(review_file_id: params[:file_id]).sort_by {|tempcomment| tempcomment[:initial_line_number]}.each {|comment|
      if (comment[:initial_line_number] <= ((params[:initial_line_number]).to_i ) and comment[:last_line_number] >= ((params[:final_line_number]).to_i)) or
        (comment[:initial_line_number] >= ((params[:initial_line_number]).to_i ) and comment[:initial_line_number] <= ((params[:final_line_number]).to_i)) or
        (comment[:initial_line_number] <= ((params[:initial_line_number]).to_i ) and comment[:last_line_number] <= ((params[:final_line_number]).to_i) and comment[:last_line_number] >= ((params[:initial_line_number]).to_i))

        assignmentparticipant = AssignmentParticipant.find(params[:participant_id])
        current_participant = AssignmentParticipant.where(parent_id: assignmentparticipant[:parent_id], user_id: session[:user].id).first

        if current_participant.id.to_s == params[:participant_id]
          authorflag = 1
        end

        member = []
        if assignmentparticipant.assignment.team_assignment
          assignmentparticipant.team.get_participants.each_with_index {|member1, index|

            member[index] = member1.id
          }
        end

        if (comment[:reviewer_participant_id] ==  current_participant.id)
          handle = "Me :"
          authorflag = 0
          # elsif  (comment[:reviewer_participant_id] == AssignmentParticipant.find_by_user_id(params[:participant_id]).id)
          elsif member.include? comment[:reviewer_participant_id] or comment[:reviewer_participant_id] == assignmentparticipant.id
            handle = "Author :"
            authorflag = 0
          else
            handle = "Reviewer"+comment[:reviewer_participant_id].to_s
          end


        #all_comment_contents << handle+": "+comment.comment_content.gsub("\n", " ")
        all_comment_contents = handle+": "+comment.comment_content.gsub("\n", " ")
        comments_in_table1=comments_in_table
        comments_in_table = ReviewCommentsHelper::construct_comments_table(all_comment_contents,comments_in_table1,i,comment.initial_line_number,comment.last_line_number,authorflag,params[:selectedFile])
        i=i+1
      end}

    comments_in_table += "</table>"
    respond_to do |format|
      format.js { render :json => comments_in_table }
    end

  end

  private

  def render_error_page(exception = nil)
    redirect_to :controller => 'content_pages', :action => 'show',
      :id => SystemSettings.first.not_found_page_id

  end


end
