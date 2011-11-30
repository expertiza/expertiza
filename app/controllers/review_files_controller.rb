class ReviewFilesController < ApplicationController
  helper :diff

  def upload_review_file
    @participant = AssignmentParticipant.find(params[:participant_id])
  end

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

    # Check if file is a zip file. If not, raise ...
    raise "Uploaded file is not a zip file. Please upload zip files only." unless
        ReviewFilesHelper::get_file_type(filename_only) == "zip"

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
        flash[:notice] = "Code Review File was successfully Uploaded."
        format.html { redirect_to :action => 'show_code_review_dashboard',
                                  :participant_id => participant.id and return}
        format.xml  { render :xml => @code_review_file, :status => :created,
                             :location => @code_review_file and return}
      else
        flash[:notice] = "Code Review File was <b>not</b> successfully" +
            "uploaded. Please Re-Submit."
        format.html { redirect_to :action => 'upload_review_file',
                                  :participant_id => participant.id and return}
        format.xml  { render :xml => @code_review_file.errors,
                             :status => :unprocessable_entity and return}
      end
    end

  end


  # Needs params[:participant_id]
  def show_code_review_dashboard
    #DEPRECATED
    participant = AssignmentParticipant.find(params[:participant_id])
    @version_number = ReviewFile.get_max_version_num(participant)

    @files = participant.get_files(
        ReviewFilesHelper::get_version_directory(participant, @version_number))
  end



  # Needs params[:participant_id]
  def show_all_submitted_files
    @participant = AssignmentParticipant.find(params[:participant_id])

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
    @file_version_map.each do |base_filename, versions|
      review_file = ReviewFile.get_file(code_review_dir, versions.sort.last,
                                        base_filename)
      @file_id_map[base_filename] = review_file ? review_file.id : nil
      @file_version_map[base_filename] =  versions.sort
    end

  end



  # params[:review_file_id] - Id of the review_file whose source is to be shown
  # params[:participant_id]
  # params[:versions] an array (in asc order) of all versions of the review file
  #                   params[:review_file_id]
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


    # TODO !!!! NEED to REFACTOR !!!!
    @shareObj = Hash.new()
    array = File.open(@current_review_file.filepath).readlines
    @shareObj['linearray1'] = array

    # TODO remove !! REDUNDANT. Already contained in @current_review_file
    @shareObj['file1'] = @current_review_file.filepath         #review_file.filepath

    first_offset = [0]
    for i in (1..array.length)
      first_offset << (first_offset[i-1] + array[i-1].size)
    end
    @shareObj['offsetarray1'] = first_offset

    #[171, 535, 330] #5, 18, 10
    @shareObj['highlightfile1'] = ReviewComment.
                                  find_all_by_file_offset(@current_review_file.id)
  end


  # params[:participant_id]
  # params[:versions] an array (in asc order) of all versions of the review file
  # params[:diff_with_file_id] - Id of current file to be diffed with
  # params[:current_version_id] the if of current version of file
  def show_code_file_diff
    @participant = AssignmentParticipant.find(params[:participant_id])

    # TODO
    # if :diff_with_file_id is nil? then default it to previous version

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

      if(first != "") ## DOLLAR HERE ##
        @first_line_num << first_count+1
        first_count += 1
      else # empty
           #processor.first_file_array[i] = ""
        @first_line_num << ""
      end


      second = processor.second_file_array[i].to_s

      if(second != "") ## DOLLAR HERE ##
        @second_line_num << second_count+1
        second_count += 1
      else
        #processor.second_file_array[i] = ""
        @second_line_num << ""
      end

      third = processor.comparison_array[i]
      first = first.gsub("\n","")
      second = second.gsub("\n","")

      # HACK ! HACK ! HACK ! TODO Initialize differently
      #if(third == DiffHelper::UNCHANGED)then @offsetswithcomments_file1 << @first_offset[i] end
      #if(third == DiffHelper::CHANGED)then @offsetswithcomments_file2 << @second_offset[i] end

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
    @shareObj['file1'] = older_file.filepath
    @shareObj['file2'] = newer_file.filepath
    @shareObj['offsetarray1'] = @first_offset
    @shareObj['offsetarray2'] = @second_offset
    @file_on_left = older_file
    @file_on_right = newer_file


    # TODO: REFACTOR!!! Code Duplication
    @tableRow_comment_map_old_version = Hash.new
    older_version_comments.each do |each_comment|
      table_row_num = @first_offset.index(each_comment.file_offset)
      @tableRow_comment_map_old_version[table_row_num] = Array.new unless
          @tableRow_comment_map_old_version[table_row_num]
      @tableRow_comment_map_old_version[table_row_num] << each_comment.comment_content.gsub("\n", " ")
    end

    @tableRow_comment_map_new_version = Hash.new
    newer_version_comments.each do |each_comment|
      table_row_num = @second_offset.index(each_comment.file_offset)
      @tableRow_comment_map_new_version[table_row_num] = Array.new unless
          @tableRow_comment_map_new_version[table_row_num]
      @tableRow_comment_map_new_version[table_row_num] << each_comment.
          comment_content.gsub("\n", " ")
    end

  end



  def submit_comment
    @comment = ReviewComment.new
    @comment.review_file_id = params[:file_id]
    @comment.file_offset = params[:file_offset]
    @comment.comment_content = params[:comment_content]
    @comment.reviewer_participant_id = AssignmentParticipant.find_by_user_id(
        session[:user].id).id
    @comment.save
  end

  def get_comments
    all_comment_contents = []
    ReviewComment.find_all_by_review_file_id_and_file_offset(
        params[:file_id], params[:file_offset]).each { |comment|
      all_comment_contents << comment.comment_content.gsub("\n", " ")
    }
    comments_in_table = ReviewCommentsHelper::constructCommentsTable(
        all_comment_contents)

    respond_to do |format|
      format.js { render :json => comments_in_table }
    end
  end



  def method2
    incoming_data = params[:key]
    puts "!!!!!!!!! METHOD 2 !!!!!!!!!!"
    puts "params[:key]: #{params[:key]}"
    #puts "incoming data #{incoming_data}"
    array_data = incoming_data.to_s.split("$")
    #puts "array_data: #{array_data}"
    puts "review_file_id: #{array_data[0]}"
    puts "file_offset: #{array_data[1]}"
    puts "comment content: #{array_data[2]}"
    puts "reviewer id: 11"


    @comment = ReviewComment.new
    @comment.review_file_id = array_data[0]
    @comment.file_offset = array_data[1]
    @comment.comment_content = array_data[2]
    #comment.reviewer_participant_id = AssignmentParticipant.find_by_user_id(session[:user_id].id).id
    @comment.reviewer_participant_id = 11
    @comment.save

    return array_data.join("$").gsub("$", "<br>")
  end

  def method3
    puts "!!!!!!!!! METHOD 3 !!!!!!!!!!"
    #puts " params[:key]: #{params[:key]}"
    #puts "incoming data #{incoming_data}"
    puts " params[:fid]: #{params[:file_id]}"
    puts " params[:offs]: #{params[:file_offset]}"
    puts " params[:lins_num]: #{params[:line_num]}"
    puts " params[:comment_content]: #{params[:comment_content]}"

    #array_data = params[:key].to_s.gsub("$","<br>")
    array_data = "FileId: #{params[:file_id]}"+
        "<br>OFFSET:#{params[:file_offset]}<br>LINE:#{params[:line_num]}"+
        "<br>CommentContent:#{params[:comment_content]}"
    puts "array_data: #{array_data}"

    respond_to do |format|
      format.js { render :json => array_data }
    end

  end



  #                <td width="28px" id="td_new_<%=i%>" bgcolor="<%=line2color%>" style=" font-weight: <%= line2_font_weight %> ; border-left: thin solid black; border-right: thin solid black; vertical-align: top;"><a class="line_number line_number_hover" style="display:block;" href="#" onclick="createComment('<%= @shareObj['linenumarray2'][i] %>', '<%= @shareObj['offsetarray2'][i] %>', '<%= @tableRow_comment_map_new_version[i] %>', '<%= @file_on_right.id %>' )"><u> <pre><%=i%></pre></u></a></td>






  ############################################################################
  ############################################################################
  ############################################################################
  ############################################################################
  ############################################################################
  ############################################################################


  def method1()
    @participant = AssignmentParticipant.find(1)

    first_file  = '/home/shyam/left.txt'
    second_file = '/home/shyam/right.txt'

    processor = DiffHelper::Processor.new(first_file,second_file)
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

      if(first != "") ## DOLLAR HERE ##
        @first_line_num << first_count+1
        first_count += 1
      else # empty
           #processor.first_file_array[i] = ""
        @first_line_num << ""
      end


      second = processor.second_file_array[i].to_s

      if(second != "") ## DOLLAR HERE ##
        @second_line_num << second_count+1
        second_count += 1
      else
        #processor.second_file_array[i] = ""
        @second_line_num << ""
      end

      third = processor.comparison_array[i]
      first = first.gsub("\n","")
      second = second.gsub("\n","")

      # HACK ! HACK ! HACK ! TODO Initialize differently
      if(third == DiffHelper::UNCHANGED)then @offsetswithcomments_file1 << @first_offset[i] end
      if(third == DiffHelper::CHANGED)then @offsetswithcomments_file2 << @second_offset[i] end

      # Remove newlines at the end of this line of code
      if(processor.first_file_array[i] != nil)
        processor.first_file_array[i] = processor.first_file_array[i].chomp
      end
      if(processor.second_file_array[i] != nil)
        processor.second_file_array[i] = processor.second_file_array[i].chomp
      end

    end

    @shareObj = Hash.new()
    @shareObj['linearray1'] = processor.first_file_array
    @shareObj['linearray2'] = processor.second_file_array
    @shareObj['comparator'] = processor.comparison_array
    @shareObj['linenumarray1'] = @first_line_num
    @shareObj['linenumarray2'] = @second_line_num
    @shareObj['offsetarray1'] = @first_offset
    @shareObj['offsetarray2'] = @second_offset
    @shareObj['file1'] = first_file
    @shareObj['file2'] = second_file
    @shareObj['highlightfile1'] = @offsetswithcomments_file1
    @shareObj['highlightfile2'] = @offsetswithcomments_file2



  end




end
