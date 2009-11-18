module SubmittedContentHelper
  
  def display_directory_tree(participant, files, flag)        
        index = 0
        check_stage = participant.assignment.get_current_stage()
        ret = '<table id="file_table" cellspacing="5">'
        ret += "<tr><th>Name</th><th>Size</th><th>Type</th><th>Date Modified</th></tr>"
        for file in files
                ret += "<tr>"
                ret += "<td valign = top>"
                if check_stage != "Complete" && flag == false
                        ret += "<input type=radio id='chk_files' name='chk_files' value='#{index}'>"
                else
                        ret += "<b>**</b>&nbsp";
                end
                ret += "<input type=hidden id='filenames_#{index}' name='filenames[#{index}]' value='#{File.dirname(file)}/#{File.basename(file)}'>"
                if File.directory?(file)
                        ret += "<a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory(#{index}); return false;'><img id='expand.#{index}' alt='Expand/Collapse' title='Expand/Collapse' src='/images/up.png'></a>&nbsp;"
                        ret += link_to File.basename(file), :controller=>'student_assignment', :action => 'submit', :id => participant.id, :download => File.basename(file), "current_folder[name]" =>  File.dirname(file)
                        ret += list_sub_directories(file, student)
                else
                        ret += link_to File.basename(file), :controller=>'student_assignment', :action => 'submit', :id => participant.id, :download => File.basename(file), "current_folder[name]" =>  File.dirname(file)
                end
                ret += "</td> <td valign = top>"
                ret += File.size(file).to_s
                ret += "</td> <td valign = top>"
                ret += File.ftype(file)
                ret += "</td> <td valign = top>"
                ret += File.mtime(file).to_s
                ret += "</td>"
                ret += "</tr>"
                index += 1
        end
        ret += "</table>"
        return ret
  end  
  
  def list_sub_directories (file, participant)
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
                        ret += link_to path, :controller=>'submitted_content', :action => 'edit', :id => student.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                        ret += list_sub_directories(disp, participant)
                else
                        ret += link_to path, :controller=>'submitted_content', :action => 'edit', :id => student.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                end
                #@i += 1
                index +=1
        }
        ret += "</ul>"
  end  
  
end
