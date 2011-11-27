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
    participant.get_files(version_dir).each { |each_file|
      @review_file = ReviewFile.new
      @review_file.filepath               = each_file.to_s
      @review_file.version_number         = new_version_number
      @review_file.author_participant_id  = participant.id

      respond_to do |format|
        if @review_file.save
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
    }

  end


  def show_code_review_dashboard
    participant = AssignmentParticipant.find(params[:participant_id])
    @version_number = ReviewFile.get_max_version_num(participant)

    @files = participant.get_files(ReviewFilesHelper::get_version_directory(
                                       participant, @version_number))
  end



  def method1

    first_file = '/home/shyam/Desktop/GIT_HELP'
    second_file = '/home/shyam/Desktop/heroku_HELP'

    processor = DiffHelper::Processor.new(first_file,second_file)
    processor.process!

    @first_line_num = []
    @second_line_num = []
    @first_offset = []
    @second_offset = []
    @firstcnt = 0
    @secondcnt = 0
    @offsetswithcomments_file1 = []
    @offsetswithcomments_file2 = []

    @first_offset << 0
    @second_offset << 0

    for i in (0..processor.absolute_line_num)

      if(i>0)
        @first_offset << (@first_offset[i-1] + processor.first_file_array[i-1].size)
        @second_offset << (@second_offset[i-1] + processor.second_file_array[i-1].size)

      end
      first =   processor.first_file_array[i].to_s
      if(first != "$")
        @first_line_num << @firstcnt+1
        @firstcnt += 1
      else
        processor.first_file_array[i] = ""
        @first_line_num << ""
      end


      second = processor.second_file_array[i].to_s

      if(second != "$")

        @second_line_num << @secondcnt+1
        @secondcnt += 1
      else
        processor.second_file_array[i] = ""
        @second_line_num << ""
      end

      third = processor.comparison_array[i]
      first = first.gsub("\n","")
      second = second.gsub("\n","")
      #print " i: ",i
      #print "first",@first_line_num[i]
      #print " FIRST:",first
      #print "first",@second_line_num[i]
      #print " SECOND: ",second
      #print "TYPE: ",third
      #puts "\n"
      if(third == 'MATCH')then @offsetswithcomments_file1 << @first_offset[i] end
      if(third == 'change')then @offsetswithcomments_file2 << @second_offset[i] end

      if(processor.first_file_array[i] != nil)
        processor.first_file_array[i] = processor.first_file_array[i].chomp
      end
      if(processor.second_file_array[i] != nil)
        processor.second_file_array[i] = processor.second_file_array[i].chomp
      end

    end

    puts @offsetswithcomments_file1
    puts @offsetswithcomments_file2

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

  def method2
    incoming_data = params[:key]
    puts (params)
    puts "#####"
    array_data = incoming_data.to_s.split("$")
    puts array_data
  end

  def method3

    puts params[:key]
    array_data = params[:key].to_s.gsub("$","<br>")
    puts array_data
    respond_to do |format|
      format.js { render :json => array_data }
    end

  end



end