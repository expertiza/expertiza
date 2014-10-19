class MoveFiles < ActiveRecord::Migration
  def self.up    
    #courses = Course.find(:all, :conditions => ['not instructor_id is null'])
    courses = Course.where.not('instructor_id = null')
    courses.each{
      | course |
      
      if course.directory_path == nil
        course.directory_path = FileHelper.clean_path(course.name)        
      end
      
      csplit = course.directory_path.split("/")
      if csplit[0] == User.find(course.instructor_id).name
        csplit[0] = nil
      end
      
      index = 0
      path = String.new
      while index < csplit.length
        if csplit[index]
          path += FileHelper.clean_path(csplit[index])
          if index < csplit.length - 1
            path += "/"
          end
        end        
        index += 1
      end
      
      if path.length == 0
        path = FileHelper.clean_path(course.name)          
      end
      
      course.directory_path = path
      course.save
      
      FileHelper.create_directory(course)
    }
    
    #assignments = Assignment.find(:all, :conditions => ['wiki_type_id = 1 and not instructor_id is null'])
    assignments = Assignment.where('wiki_type_id = 1 and instructor_id != null')
    assignments.each{
      | assignment |
      directories = Assignment.find_all_by_directory_path(assignment.directory_path)
      if directories.length ==  1
        oldpath = Rails.root + "/pg_data/"+ assignment.directory_path
         if assignment.name == 'Another assignment'
            puts assignment.directory_path
            puts assignment.directory_path.length
         end     
      
         if assignment.directory_path == nil or assignment.directory_path.length == 0
          assignment.directory_path = FileHelper.clean_path(assignment.name)        
        end
      
        asplit = assignment.directory_path.split("/")      
        if asplit[0] == User.find(assignment.instructor_id).name
          asplit[0] = nil
        end
      
        if assignment.course_id > 0 and asplit[1] == Course.find(assignment.course_id).directory_path
         asplit[1] = nil
        end
      
        index = 0
        path = String.new
        while index < asplit.length
          if asplit[index]
            path += FileHelper.clean_path(asplit[index])
           if index < asplit.length - 1
             path += "/"
           end
         end        
         index += 1
       end
      
      if path.length == 0
        path = FileHelper.clean_path(assignment.name)          
      end  
           
      assignment.directory_path = path                
      assignment.save
      if oldpath != assignment.dir_path
        FileHelper.create_directory(assignment)    
        oldcontents = Dir.glob(oldpath + "/*")        
        FileUtils.mv(oldcontents,assignment.dir_path)
      end
    else
      puts "Two or more assignments exist for the same path. Assignment: "+assignment.name+" Path: "+assignment.directory_path
    end
    }
  end

  def self.down
  end
end
