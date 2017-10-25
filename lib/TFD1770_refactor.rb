module Instance_method
  def files(directory)
    files_list = Dir[directory + "/*"]
    files = []

    files_list.each do |file|
      if File.directory?(file)
        dir_files = files(file)
        dir_files.each {|f| files << f }
      end
      files << file
    end
    files
  end
end

module Class_method
  def check_info_and_create(row, _row_header = nil, session)
    raise ArgumentError, "No user id has been specified." if row.empty?
    user = User.find_by(name:row[0])
    if user.nil?
      raise ArgumentError, "The record containing #{row[0]} does not have enough items." if row.length < 4
      attributes = ImportFileHelper.define_attributes(row)
      user = ImportFileHelper.create_new_user(attributes, session)
    end
  end
end

