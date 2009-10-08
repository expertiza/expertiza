module ReviewMappingHelper
  
  def self.delete_mappings(mappings,flash,contributor = nil)  
    title = "A delete action failed:<br/>"
    msg = ""    
    mappings.each{ 
       |mapping|
       begin
         mapping.delete
       rescue
         msg += "&nbsp;&nbsp;&nbsp;" + $! + "<a href='/review_mapping/delete_review/"+mapping.id.to_s+"'>Delete these reviews</a>?<br/>"
       end
    }
    if msg.length > 0
      title += msg
      flash[:error] = title      
    elsif contributor.nil?
      flash[:note] = "All review and metareview mappings have been deleted."
    else
      flash[:note] = "All review mappings for \""+contributor.name+"\" have been deleted."      
    end
      
  end  
end
