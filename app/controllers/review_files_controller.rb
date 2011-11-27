class ReviewFilesController < ApplicationController

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




end