class ReviewFilesController < ApplicationController
  rescue_from Exception, :with => :render_error_page
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

    # Check if file is a zip file. If not, display flash message.
    if ReviewFilesHelper::get_file_type(filename_only) != "zip"
      flash[:error] = "Uploaded file is not a zip file. Please upload zip files" +
        " only."
      redirect_to :action => 'show_all_submitted_files',
                  :participant_id => participant.id and return
    end


    # Copy zip file into version_dir
    File.open(full_filename, "wb") { |f| f.write(file.read) }

    # Unzip submission
    SubmittedContentHelper::unzip_file(full_filename, version_dir, true)

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
      @participant.team.get_participants.each { |member|
        all_review_files += ReviewFile.find_all_by_author_participant_id(member.id)
      }
    else
      all_review_files = ReviewFile.find_all_by_author_participant_id(@participant.id)
    end

    # For each file in the above list find out the various versions in which it occurs
    @file_version_map = Hash.new
    all_review_files.each do |each_file|
      @file_version_map[File.basename(each_file.filepath)] = Array.new unless
          @file_version_map[File.basename(each_file.filepath)]
      @file_version_map[File.basename(each_file.filepath)] << each_file.version_number
    end

    code_review_dir = ReviewFilesHelper::get_code_review_file_dir(@participant)

    # For each file in the above map create a new map, to store the
    #   filename -> review_file_id mapping.
    @file_id_map = Hash.new
    @latest_version_number = 0
    @file_version_map.each do |base_filename, versions|
      review_file = ReviewFile.get_file(code_review_dir, versions.sort.last,
                                        base_filename)
      @file_id_map[base_filename] = review_file ? review_file.id : nil
      @file_version_map[base_filename] =  versions.sort
      @latest_version_number = (@file_version_map[base_filename][-1] >
          @latest_version_number) ? @file_version_map[base_filename][-1] :
                                    @latest_version_number
    end

  end



  # This method is used to generate the view where the particular code file is
  # viewed 'individually' (not diff).
  # params[:review_file_id] - Id of the review_file whose source is to be shown
  # params[:participant_id]
  # params[:versions] an array (in asc order) of all versions of the review file
  #                   contained in params[:review_file_id]
  def show_code_file
    @participant = AssignmentParticipant.find(params[:participant_id])
    @current_review_file = ReviewFile.find(params[:review_file_id])

    @version_fileId_map = Hash.new
    params[:versions].each do |each_version|
      this_file = ReviewFile.get_file(
          ReviewFilesHelper::get_code_review_file_dir(@participant),
          each_version, File.basename(@current_review_file.filepath))
      @version_fileId_map[each_version] = this_file ? this_file.id : nil
    end

    file_contents = File.open(@current_review_file.filepath).readlines

    offset_array = [0]
    for i in (1..file_contents.length)
      offset_array << (offset_array[i-1] + file_contents[i-1].size-1)
    end

    @shareObj = Hash.new()
    @shareObj['linearray2'] = file_contents
    @shareObj['offsetarray2'] = offset_array

    newer_version_comments = ReviewComment.find_all_by_review_file_id(
        @current_review_file.id)

    @highlight_cell_right_file = Hash.new
    newer_version_comments.each do |each_comment|
      table_row_num = offset_array.index(each_comment.file_offset)
      table_row_num = offset_array.length + 1 unless table_row_num

      # Increment table_row_num until a non "" string is encountered in @first_line_num
      while ( (file_contents[table_row_num].nil? or
          file_contents[table_row_num].blank?) and
          table_row_num < file_contents.length)
        table_row_num += 1
      end

      @highlight_cell_right_file[table_row_num] = true
    end

  end


  # params[:participant_id]
  # params[:versions] an array (in asc order) of all versions of the review file
  # params[:diff_with_file_id] - Id of current file to be diffed with
  # params[:current_version_id] the if of current version of file
  def show_code_file_diff
    @participant = AssignmentParticipant.find(params[:participant_id])

    # Get the filepath of both the files.
    older_file = ReviewFile.find(params[:current_version_id])
    newer_file = ReviewFile.find(params[:diff_with_file_id])

    @current_review_file = older_file

    @version_fileId_map = Hash.new
    params[:versions].each do |each_version|
      this_file = ReviewFile.get_file(
          ReviewFilesHelper::get_code_review_file_dir(@participant),
          each_version, File.basename(@current_review_file.filepath))
      @version_fileId_map[each_version] = this_file ? this_file.id : nil
    end

    # Swap them if older is more recent than newer
    if older_file.version_number > newer_file.version_number
      temp = older_file
      older_file = newer_file
      newer_file = temp
    end

    processor = DiffHelper::Processor.new(older_file.filepath, newer_file.filepath)
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

      if i > 0
        @first_offset  << (@first_offset[i-1]  + processor.first_file_array[i-1].size)
        @second_offset << (@second_offset[i-1] + processor.second_file_array[i-1].size)
      end

      first = processor.first_file_array[i].to_s

      if(first != "")
        @first_line_num << first_count+1
        first_count += 1
      else # empty
        @first_line_num << nil
      end

      second = processor.second_file_array[i].to_s

      if(second != "")
        @second_line_num << second_count+1
        second_count += 1
      else
        @second_line_num << nil
      end

      # Remove newlines at the end of this line of code
      if(processor.first_file_array[i] != nil)
        processor.first_file_array[i] = processor.first_file_array[i].chomp
      end
      if(processor.second_file_array[i] != nil)
        processor.second_file_array[i] = processor.second_file_array[i].chomp
      end

    end

    older_version_comments = ReviewComment.find_all_by_review_file_id(older_file.id)
    newer_version_comments = ReviewComment.find_all_by_review_file_id(newer_file.id)

    @shareObj = Hash.new()
    @shareObj['linearray1'] = processor.first_file_array
    @shareObj['linearray2'] = processor.second_file_array
    @shareObj['comparator'] = processor.comparison_array
    @shareObj['linenumarray1'] = @first_line_num
    @shareObj['linenumarray2'] = @second_line_num
    @shareObj['offsetarray1'] = @first_offset
    @shareObj['offsetarray2'] = @second_offset
    @file_on_left = older_file
    @file_on_right = newer_file


    # REFACTOR: Code Duplication

    @highlight_cell_left_file = Hash.new
    older_version_comments.each do |each_comment|
      table_row_num = @first_offset.index(each_comment.file_offset)
      table_row_num = @first_offset.length + 1 unless table_row_num

      # Increment table_row_num until a non "" string is encountered in @first_line_num
      while (@first_line_num[table_row_num].nil? and
          table_row_num < @first_line_num.length)
        table_row_num += 1
      end

      @highlight_cell_left_file[table_row_num] = true
    end


    @highlight_cell_right_file = Hash.new
    newer_version_comments.each do |each_comment|
      table_row_num = @second_offset.index(each_comment.file_offset)
      table_row_num = @second_offset.length + 1 unless table_row_num

      # Increment table_row_num until a non "" string is encountered in @second_line_num
      while (@second_line_num[table_row_num].nil? and
          table_row_num < @second_line_num.length)
        table_row_num += 1
      end

      @highlight_cell_right_file[table_row_num] = true
    end

  end



  def submit_comment
    @comment = ReviewComment.new
    @comment.review_file_id = params[:file_id]
    @comment.file_offset = params[:file_offset]
    @comment.comment_content = params[:comment_content].gsub("\n", " ")
    @comment.reviewer_participant_id = AssignmentParticipant.find_by_user_id(
        session[:user].id).id
    @comment.save
  end

  # Needs params[:file_id], params[:file_offset]
  def get_comments
    all_comment_contents = []
    ReviewComment.find_all_by_review_file_id_and_file_offset(
        params[:file_id], params[:file_offset]).each { |comment|
      all_comment_contents << comment.comment_content.gsub("\n", " ")
    }
    comments_in_table = ReviewCommentsHelper::construct_comments_table(
        all_comment_contents)

    respond_to do |format|
      format.js { render :json => comments_in_table }
    end
  end

  private

  def render_error_page(exception = nil)
    redirect_to :controller => 'content_pages', :action => 'show',
                :id => SystemSettings.find(:first).not_found_page_id

  end

end
