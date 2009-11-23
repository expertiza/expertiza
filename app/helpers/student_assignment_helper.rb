module StudentAssignmentHelper

  COMPLETE = "Complete"

  def self.find_current_stage(assignment_id)
    due_dates = DueDate.find(:all,
                 :conditions => ["assignment_id = ?", assignment_id],
                 :order => "due_at DESC")

    if due_dates != nil and due_dates.size > 0
      if Time.now > due_dates[0].due_at
        return COMPLETE
      else
        i = 0
        for due_date in due_dates
          if Time.now < due_date.due_at and
             (due_dates[i+1] == nil or Time.now > due_dates[i+1].due_at)
            return due_date
          end
          i = i + 1
        end
      end
    end
  end

  def self.get_current_stage(assignment_id)
    due_date = find_current_stage(assignment_id)
    if due_date == nil or due_date == COMPLETE
      return COMPLETE
    else
      return DeadlineType.find(due_date.deadline_type_id).name
    end
  end
  
  def self.get_stage_deadline(assignment_id)
    due_date = find_current_stage(assignment_id)
    if due_date == nil or due_date == COMPLETE
      return due_date
    else
      return due_date.due_at.to_s
    end
  end

  def self.get_grade(participant_id)
    return 0
  end

  def self.date_plus_days(days)
    t = Time.now
    t = t + days * (60*60*24)
    return t.strftime("%Y-%m-%d")
  end


  
  def list_sub_directories (file, student)
        index = 0
        ret = "<ul id= 'subdir."+@i.to_s+"."+index.to_s+"'>"
        #@i += 1
        Dir.foreach( file ) {|path|
                next if path == "." or path == ".." or path == ".svn"
                @i += 1
                disp = file + "/" + path
                display = File.basename(file) +"/"+ path
                ret += "<li>"
                        if @check_stage != "Complete" && @flag == false
                                ret += "<input type=radio id='chk_files' name='chk_files' value='"+@i.to_s+"'>"
                        end
                        ret += "<input type=hidden id='filenames_"+@i.to_s+"' name='filenames["+@i.to_s+"]' value='"+File.dirname(disp)+"/" +File.basename(path)+"'>"
                if File.ftype( disp ) == "directory"
                        ret += "<a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory("+@i.to_s+"); return false;'><img id='expand."+@i.to_s+"' alt='Expand/Collapse' title='Expand/Collapse' src='/images/up.png'></a>&nbsp;"
                        ret += link_to path, :controller=>'student_assignment', :action => 'submit', :id => student.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                        ret += list_sub_directories(disp, student)
                else
                        ret += link_to path, :controller=>'student_assignment', :action => 'submit', :id => student.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                end
                #@i += 1
                index +=1
        }
        ret += "</ul>"
  end
  def display_directory_tree(files, student, flag)
        @i = 0
        @check_stage = StudentAssignmentHelper.get_current_stage(student.assignment.id)
        ret = ""
        @flag = flag
        for file in files
                ret += "<tr>"
                ret += "<td valign = top>"
                if @check_stage != "Complete" && @flag == false
                        ret += "<input type=radio id='chk_files' name='chk_files' value='"+@i.to_s+"'>"
                else
                        ret += "<b>**</b>&nbsp";
                end
                ret += "<input type=hidden id='filenames_"+@i.to_s+"' name='filenames["+@i.to_s+"]' value='"+File.dirname(file)+ "/" +File.basename(file)+"'>"
                if File.directory?(file)
                        ret += "<a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory("+@i.to_s+"); return false;'><img id='expand."+@i.to_s+"' alt='Expand/Collapse' title='Expand/Collapse' src='/images/up.png'></a>&nbsp;"
                        ret += link_to File.basename(file), :controller=>'student_assignment', :action => 'submit', :id => student.id, :download => File.basename(file), "current_folder[name]" =>  File.dirname(file)
                        ret += list_sub_directories(file, student)
                else
                        ret += link_to File.basename(file), :controller=>'student_assignment', :action => 'submit', :id => student.id, :download => File.basename(file), "current_folder[name]" =>  File.dirname(file)
                end
                ret += "</td> <td valign = top>"
                ret += File.size(file).to_s
                ret += "</td> <td valign = top>"
                ret += File.ftype(file)
                ret += "</td> <td valign = top>"
                ret += File.mtime(file).to_s
                ret += "</td>"
                ret += "</tr>"
                @i += 1
        end
        @ret = ret
        return ret

  end

end