module ReviewFilesHelper
  CODE_REVIEW_DIR_SUFFIX  = '_code_review_files'
  VERSION_DIR_SUFFIX      = 'version_'

  # Removes invalid chars (valid are period, underscore, forward_slash,
  #   alphanumeric characters). Replaces whitespace with underscore. Returns only
  #   the base filename (minus the directory e.g. /dir1/dir2/abc.rb => abc.rb)
  def self.get_safe_filename(filename)
    safe_filename = filename.gsub(/\\/,"/")
    safe_filename = FileHelper::sanitize_filename(safe_filename) # returns only the filename -- sanitized (but has whitespace)
    safe_filename = File.split(safe_filename).last.gsub(" ",'_')
    return safe_filename
  end

  # Returns the type (extension) of the file.
  def self.get_file_type file_name
    base = File.basename(file_name)
    if base.split(".").size > 1
      return base.split(".")[base.split(".").size-1]
    end
  end

  # Calculate version directory
  def self.get_version_directory(participant, version_number)
    return participant.dir_path.to_s + CODE_REVIEW_DIR_SUFFIX + '/' +
      VERSION_DIR_SUFFIX + version_number.to_s + '/'
  end

  # Calculate code review file directory
  def self.get_code_review_file_dir(participant)
    return participant.dir_path.to_s + CODE_REVIEW_DIR_SUFFIX + '/'
  end

  def self.populate_shareObj(processor)
    first_line_num = []
    second_line_num = []
    first_offset = []
    second_offset = []
    offsetswithcomments_file1 = []
    offsetswithcomments_file2 = []

    first_offset << 0
    second_offset << 0

    first_count = 0
    second_count = 0
    for i in (0..processor.absolute_line_num)
      first_offset = ReviewFile.get_first_offset(processor, i, @first_offset)
      second_offset = ReviewFile.get_second_offset(processor, i, @second_offset)

      first_line_num_new = Hash.new
      first_line_num_new = ReviewFile.get_first_line_num(processor, i, first_count)

      first_line_num << first_line_num[:first_line_num]
      first_count = first_line_num[:first_count]

      second_line_num_new = Hash.new
      second_line_num_new = ReviewFile.get_second_line_num(processor, i,second_count)
      second_line_num << second_line_num[:second_line_num]
      second_count = second_line_num[:second_count]

      # Remove newlines at the end of this line of code
      processor = ReviewFile.get_first_file_array(processor, i)
      processor = ReviewFile.get_second_file_array(processor, i)

      shareObj = Hash.new()
      shareObj['linearray1'] = processor.first_file_array
      shareObj['linearray2'] = processor.second_file_array
      shareObj['comparator'] = processor.comparison_array
      shareObj['linenumarray1'] = first_line_num
      shareObj['linenumarray2'] = second_line_num
      shareObj['offsetarray1'] = first_offset
      shareObj['offsetarray2'] = second_offset

      return first_line_num, second_line_num, first_count, second_count, shareObj
    end
  end

  def self.find_review_files(participant) 
    # Find all files over all versions submitted by the team

    all_review_files = Array.new

    if participant.assignment.team_assignment
      participant.team.get_participants.each_with_index { |member,index|
        all_review_files += ReviewFile.where(author_participant_id: member.id)
      }
    else
      all_review_files = ReviewFile.where(author_participant_id: @participant.id)
    end

    all_review_files
  end

  def self.find_review_versions(all_review_files) 
    file_version_map = Hash.new

    all_review_files.each_with_index do |each_file,index|
      file_version_map[File.basename(each_file.filepath)] = Array.new unless
      file_version_map[File.basename(each_file.filepath)]
      file_version_map[File.basename(each_file.filepath)] << each_file.version_number
    end

    return file_version_map
  end


end

