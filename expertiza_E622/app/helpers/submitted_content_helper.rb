module SubmittedContentHelper
  
  def display_directory_tree(participant, files, flag)        
        index = 0
        participant = @participant if @participant # TODO: Verify why this is needed
        assignment = participant.assignment # participant is @map.contributor
        topic_id = participant.topic_id     # participant is @map.reviewer
        check_stage = assignment.get_current_stage(topic_id)

        ret = "\n<table id='file_table' cellspacing='5'>"
        ret += "\n   <tr><th>Name</th><th>Size</th><th>Type</th><th>Date Modified</th></tr>"
        for file in files
                ret += "\n   <tr>"
                ret += "\n   <td valign = top>\n      "
                if check_stage != "Complete" && flag == false
                        ret += "<input type=radio id='chk_files' name='chk_files' value='#{index}'>"
                else
                        ret += "<b>**</b>&nbsp";
                end
                ret += "\n      <input type=hidden id='filenames_#{index}' name='filenames[#{index}]' value='#{File.basename(file)}'>"
                ret += "\n      <input type=hidden id='directories_#{index}' name='directories[#{index}]' value='#{File.dirname(file)}'>"
                if File.directory?(file)
                        #ret += "\n      <a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory(#{index}); return false;'><img id='expand.#{index}' alt='Expand/Collapse' title='Expand/Collapse' src='/images/up.png'></a>&nbsp;"
                        ret += link_to File.basename(file), :controller => 'submitted_content', :action => 'edit', :id => participant.id, "current_folder[name]" =>  file
                        #ret += list_sub_directories(file, participant)
                else
                        ret += "\n      "
                        parentFolder = File.dirname(file)
                        if parentFolder != participant.get_path
                          parentFolder.sub!(participant.get_path+"/","")
                          parentFolder += "/"
                        else
                          parentFolder = ""
                        end
                        
                        location = parentFolder + File.basename(file)
                        ret += link_to location, :controller => 'submitted_content', :action => 'download', :id => participant.id, :download => File.basename(file), "current_folder[name]" =>  File.dirname(file)
                end
                ret += "\n   </td>\n   <td valign = top>\n"
                ret += File.size(file).to_s
                ret += "\n   </td>\n   <td valign = top>\n"
                ret += File.ftype(file)
                ret += "\n   </td>\n   <td valign = top>\n"
                ret += File.mtime(file).to_s
                ret += "\n   </td>\n   </tr>"
                index += 1
        end
        ret += "\n</table>"
        return ret
  end  
  
  def list_sub_directories (file, participant)
        index = 0
        ret = "<ul id= 'subdir."+index.to_s+"."+index.to_s+"'>"       
        Dir.foreach( file ) {|path|
                next if path == "." or path == ".." or path == ".svn"
                index += 1
                disp = file + "/" + path
                display = File.basename(file) +"/"+ path
                ret += "<li>"
                        if @check_stage != "Complete" && @flag == false
                                ret += "<input type=radio id='chk_files' name='chk_files' value='#{index}'>"
                        end
                        ret += "<input type=hidden id='filenames_#{index}' name='filenames[#{index}]' value='"+File.dirname(disp)+"/" +File.basename(path)+"'>"
                if File.ftype( disp ) == "directory"
                        ret += "<a title='Expand/Collapse' href='#' onclick='javascript:collapseSubDirectory(#{index}); return false;'><img id='expand.#{index}' alt='Expand/Collapse' title='Expand/Collapse' src='/images/up.png'></a>&nbsp;"
                        ret += link_to path, :controller=>'submitted_content', :action => 'edit', :id => participant.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                        ret += list_sub_directories(disp, participant)
                else
                        ret += link_to path, :controller=>'submitted_content', :action => 'edit', :id => participant.id, :download => File.basename(path), "current_folder[name]" =>  File.dirname(disp)
                        ret += "</li>"
                end
        }
        ret += "</ul>"
  end  
  
  # Installing RubyZip
  # run the command,  gem install rubyzip
  # restart the server
  def self.unzip_file(file_name, unzip_dir, should_delete)
   #begin
      Zip::ZipFile::open(file_name) {
        |zf| zf.each { |e|
          safename = FileHelper::sanitize_filename(e.name);
          fpath = File.join(unzip_dir, safename)
          FileUtils.mkdir_p(File.dirname(fpath))
          zf.extract(e, fpath) } }

          if should_delete
            # The zip file is no longer needed, so delete it
            File.delete(file_name)
          end
    #rescue
    #end
  end  
  
end
