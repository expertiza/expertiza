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
    return participant.get_path.to_s + CODE_REVIEW_DIR_SUFFIX + '/' +
        VERSION_DIR_SUFFIX + version_number.to_s + '/'
  end

  # Calculate code review file directory
  def self.get_code_review_file_dir(participant)
    return participant.get_path.to_s + CODE_REVIEW_DIR_SUFFIX + '/'
  end



end

