class MoveFiles < ActiveRecord::Migration[4.2]
  def self.up    
    courses = Course.where(['not instructor_id is null'])
    courses.each do |course|
      if course.directory_path.nil?
        course.directory_path = FileHelper.clean_path(course.name)
      end

      csplit = course.directory_path.split('/')
      csplit[0] = nil if csplit[0] == User.find(course.instructor_id).name

      index = 0
      path = ''
      while index < csplit.length
        if csplit[index]
          path += FileHelper.clean_path(csplit[index])
          path += '/' if index < csplit.length - 1
        end
        index += 1
      end

      path = FileHelper.clean_path(course.name) if path.empty?

      course.directory_path = path
      course.save

      FileHelper.create_directory(course)
    end

    assignments = Assignment.where(['wiki_type_id = 1 and not instructor_id is null'])
    assignments.each do |assignment|
      directories = Assignment.find_all_by(directory_path: assignment.directory_path)
      next unless directories.length == 1

      oldpath = Rails.root + '/pg_data/' + assignment.directory_path
      if assignment.directory_path.nil? || assignment.directory_path.empty?
        assignment.directory_path = FileHelper.clean_path(assignment.name)
     end

      asplit = assignment.directory_path.split('/')
      asplit[0] = nil if asplit[0] == User.find(assignment.instructor_id).name

      if (assignment.course_id > 0) && (asplit[1] == Course.find(assignment.course_id).directory_path)
        asplit[1] = nil
      end

      index = 0
      path = ''
      while index < asplit.length
        if asplit[index]
          path += FileHelper.clean_path(asplit[index])
          path += '/' if index < asplit.length - 1
       end
        index += 1
     end

      path = FileHelper.clean_path(assignment.name) if path.empty?

      assignment.directory_path = path
      assignment.save
      next unless oldpath != assignment.dir_path

      FileHelper.create_directory(assignment)
      oldcontents = Dir.glob(oldpath + '/*')
      FileUtils.mv(oldcontents, assignment.dir_path)
    end
  end

  def self.down; end
end
