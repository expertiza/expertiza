class ReviewMappingController < ApplicationController
  auto_complete_for :user, :name
  
  def auto_complete_for_user_name
    name = params[:user][:name]+"%"
    puts "************"
    puts session[:contributor]    
    puts "************"
    assignment_id = session[:contributor].parent_id
    @users = User.find(:all, :include => :participants, 
      :conditions => ['participants.type = "AssignmentParticipant" and users.name like ? and participants.parent_id = ?',name,assignment_id], 
      :order => 'name') 

    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  
  def select_reviewer
    assignment = Assignment.find(params[:id])     
    @contributor = assignment.get_contributor(params[:contributor_id])
    session[:contributor] = @contributor
  end
  
  def select_metareviewer
    @mapping = ResponseMap.find(params[:id])    
  end  
  
  def add_reviewer 
    assignment = Assignment.find(params[:id])  
    msg = String.new
    begin
      user = get_user(params)      
      regurl = url_for :action => 'add_user_to_assignment', 
          :id => assignment.id, 
          :user_id => user.id, 
          :contributor_id => params[:contributor_id]                     
      reviewer = get_reviewer(user,assignment,regurl)
      
      if assignment.team_assignment
        if TeamReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:id],reviewer.id]).nil?
          TeamReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
        else
          raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      else
        if ParticipantReviewResponseMap.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',params[:id],reviewer.id]).nil?
           ParticipantReviewResponseMap.create(:reviewee_id => params[:contributor_id], :reviewer_id => reviewer.id, :reviewed_object_id => assignment.id)
        else
           raise "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      end
    rescue
       msg = $!
    end    
    redirect_to :action => 'list_mappings', :id => assignment.id, :msg => msg    
  end
  
  def add_metareviewer    
    mapping = ResponseMap.find(params[:id])  
    msg = String.new
    begin
      user = get_user(params)   
      regurl = url_for :action => 'add_user_to_assignment', :id => mapping.id, :user_id => user.id               
      reviewer = get_reviewer(user,mapping.assignment,regurl)
      
      if MetareviewResponseMap.find(:first, :conditions => ['reviewed_object_id = ? and reviewer_id = ?',mapping.id,reviewer.id]) != nil
         raise "The metareviewer \""+reviewer.user.name+"\" is already assigned to this reviewer."
      end
      MetareviewResponseMap.create(:reviewed_object_id => mapping.id,                        
                                   :reviewer_id => reviewer.id,
                                   :reviewee_id => mapping.reviewer.id)                         
    rescue  
      msg = $!
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id, :msg => msg                                  
  end 
  
  def get_user(params)      
      if params[:user_id]
        user = User.find(params[:user_id])
      else
        user = User.find_by_name(params[:user][:name])
      end    
      if user.nil?
         newuser = url_for :controller => 'users', :action => 'new' 
         raise "Please <a href='#{newuser}'>create an account</a> for this user to continue."
      end 
      return user
  end
  
  def get_reviewer(user,assignment,regurl)      
      reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(user.id,assignment.id)
      if reviewer.nil?
         raise "\"#{user.name}\" is not a participant in the assignment. Please <a href='#{regurl}'>register</a> this user to continue."
     end
     return reviewer
  end  
  
  
  def add_user_to_assignment
    if params[:contributor_id]
      assignment = Assignment.find(params[:id]) 
    else
      mapping = ResponseMap.find(params[:id])
      assignment = mapping.assignment
    end
         
    user = User.find(params[:user_id])
    begin
      assignment.add_participant(user.name)
    rescue
      flash[:error] = $!
    end    
    if params[:contributor_id]
      redirect_to :action => 'add_reviewer',     :id => params[:id], :user_id => user.id, :contributor_id => params[:contributor_id]
    else
      redirect_to :action => 'add_metareviewer', :id => params[:id], :user_id => user.id
    end
  end
  
 
  def delete_all_reviewers_and_metareviewers
    assignment = Assignment.find(params[:id])
    failedCount = delete_mappings(assignment.review_mappings,params[:force])   
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id], :force => 1
      url_no  = url_for :action => 'delete_all_reviewers_and_metareviewers', :id => params[:id]
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"            
    else
      flash[:note] = "All review mappings for this assignment have been deleted."             
    end     
    redirect_to :action => 'list_mappings', :id => params[:id]   
  end  
  
  def delete_all_reviewers      
    assignment = Assignment.find(params[:id])
    contributor = assignment.get_contributor(params[:contributor_id])
    mappings = contributor.review_mappings
    
    failedCount = delete_mappings(mappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id, :force => 1
      url_no  = url_for :action => 'delete_all_reviewers', :id => assignment.id, :contributor_id => contributor.id
      flash[:error] = "A delete action failed:<br/>#{failedCount} reviews and/or metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"            
    else
      flash[:note] = "All review mappings for \""+contributor.name+"\" have been deleted."             
    end      
    redirect_to :action => 'list_mappings', :id => assignment.id
  end
  
  def delete_all_metareviewers    
    mapping = ResponseMap.find(params[:id])    
    
    mmappings = MetareviewResponseMap.find_all_by_reviewed_object_id(mapping.id)
    failedCount = delete_mappings(mmappings, params[:force])
    if failedCount > 0
      url_yes = url_for :action => 'delete_all_metareviewers', :id => mapping.id, :force => 1
      url_no  = url_for :action => 'delete_all_metareviewers', :id => mapping.id
      flash[:error] = "A delete action failed:<br/>#{failedCount} metareviews exist for these mappings. Delete these mappings anyway?&nbsp;<a href='#{url_yes}'>Yes</a>&nbsp;|&nbsp;<a href='#{url_no}'>No</a><BR/>"                  
    else
      flash[:note] = "All metareview mappings for contributor \""+mapping.reviewee.name+"\" and reviewer \""+mapping.reviewer.name+"\" have been deleted."      
    end
    redirect_to :action => 'list_mappings', :id => mapping.assignment.id
  end   
  
  def delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each{ 
       |mapping|
       assignment_id = mapping.assignment.id
       begin         
         mapping.delete(force)
       rescue
         failedCount += 1
       end
    } 
    return failedCount
  end
        
  def delete_participant
    contributor = AssignmentParticipant.find(params[:id])
    name = contributor.name
    assignment_id = contributor.assignment
    begin
      contributor.destroy
      flash[:note] = "\"#{name}\" is no longer a participant in this assignment."      
    rescue
      flash[:error] = "\"#{name}\" was not removed. Please ensure that \"#{name}\" is not a reviewer or metareviewer and try again."
    end     
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_reviewer
    mapping = ResponseMap.find(params[:id]) 
    assignment_id = mapping.assignment.id
    begin
      mapping.delete
      flash[:note] = "The review mapping for \""+mapping.reviewee.name+"\" and \""+mapping.reviewer.name+"\" have been deleted."        
    rescue      
      flash[:error] = "A delete action failed:<br/>" + $! + "Delete this mapping anyway?&nbsp;<a href='/review_mapping/delete_review/"+mapping.id.to_s+"'>Yes</a>&nbsp;|&nbsp;<a href='/review_mapping/list_mappings/#{assignment_id}'>No</a>"     
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_metareviewer
    mapping = MetareviewResponseMap.find(params[:id])
    assignment_id = mapping.assignment.id
    flash[:note] = "The metareview mapping for "+mapping.reviewee.name+" and "+mapping.reviewer.name+" have been deleted."
    
    begin 
      mapping.delete
    rescue
      flash[:error] = "A delete action failed:<br/>" + $! + "<a href='/review_mapping/delete_metareview/"+mapping.id.to_s+"'>Delete this mapping anyway>?"     
    end
    
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  
  def delete_review
    mapping = ResponseMap.find(params[:id])
    mapping.response.delete          
    redirect_to :action => 'delete_reviewer', :id => mapping.id
  end
  
  def delete_metareview
    mapping = MetareviewResponseMap.find(params[:id])
    metareview = mapping.response
    metareview.delete
    mapping.delete
    redirect_to :action => 'list_mappings', :id => mapping.review_mapping.assignment_id
  end
  
  def delete_rofreviewer
    mapping = ResponseMapping.find(params[:id])
    revmapid = mapping.review_mapping.id
    mapping.delete
    
    flash[:note] = "The review of reviewer has been deleted."
    redirect_to :action => 'list_rofreviewers', :id => revmapid  
  end     
    
  def list       
    all_assignments = Assignment.find(:all, :order => 'name', :conditions => ["instructor_id = ?",session[:user].id])
    
    letter = params[:letter]
    if letter == nil
      letter = all_assignments.first.name[0,1].downcase
    end 
    
    @letters = Array.new
    @pages, @assignments = paginate :assignments, :order => 'name', :per_page => 10,  :conditions => ["instructor_id = ? and substring(name,1,1) = ?",session[:user].id, letter]    
  
    all_assignments.each {
       | assignObj |
       first = assignObj.name[0,1].downcase
       if not @letters.include?(first)
          @letters << first  
       end
    }       
  end    
  
  def list_mappings
    if params[:msg]
      flash[:error] = params[:msg]
    end
    @assignment = Assignment.find(params[:id])       
    if @assignment.team_assignment
      @items = AssignmentTeam.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.name <=> b.name}
    else
      @items = AssignmentParticipant.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.fullname <=> b.fullname}
    end
  end
  
  def list_sortable
    @assignment = Assignment.find(params[:id])
    @entries = Array.new 
    index = 0
    if @assignment.team_assignment
      contributors = AssignmentTeam.find_all_by_parent_id(@assignment.id)       
    else
      contributors = AssignmentParticipant.find_all_by_parent_id(@assignment.id)
    end
    contributors.sort!{|a,b| a.name <=> b.name}    
    contributors.each{
      |contrib|
      review_mappings = ResponseMap.find_all_by_reviewed_object_id_and_reviewee_id(@assignment.id,contrib.id)
      
      if review_mappings.length == 0
        single = Array.new
        single[0] = contrib.name
        single[1] = "&nbsp;"
        single[2] = "&nbsp;"
        @entries[index] = single
        index += 1
      else
      review_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
      review_mappings.each{
        |review_map|
        metareview_mappings = MetareviewResponseMap.find_all_by_reviewed_object_id(review_map.id)
        if metareview_mappings.length == 0
          single = Array.new
          single[0] = contrib.name
          single[1] = review_map.reviewer.name
          single[2] = "&nbsp;"
          @entries[index] = single
          index += 1
        else
          metareview_mappings.sort!{|a,b| a.reviewer.name <=> b.reviewer.name}
          metareview_mappings.each{
            |metareview_map|
              single = Array.new
              single[0] = contrib.name
              single[1] = review_map.reviewer.name
              if metareview_map.review_reviewer == nil
                single[2] = metareview_map.reviewer.name
              else
                single[2] = metareview_map.review_reviewer.name
              end
              @entries[index] = single
              index += 1
          }
        end
      }
      end
    }
  end  
  
  def generate_reviewer_mappings
    assignment = Assignment.find(params[:id])
    assignment.update_attribute('review_strategy_id',1)
    assignment.update_attribute('mapping_strategy_id',1)    
   
    mapping_strategy = {}
    params[:selection].each{|a|
      if a[0] =~ /^m_/
        mapping_strategy[a[0]] = a[1]
      end
    }
    
    if assignment.update_attributes(params[:assignment])
      #begin
        assignment.assign_reviewers(mapping_strategy)        
      #rescue
        #flash[:error] = "Reviewer assignment failed. Cause: " + $!
      #ensure
        redirect_to :action => 'list_mappings', :id => assignment.id
      #end
    else
      @wiki_types = WikiType.find_all
      redirect_to :action => 'list_mappings', :id => assignment.id
    end    
  end  
  
  
  def select_mapping
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.find(:all, :order => 'name')
    @mapping_strategies = MappingStrategy.find(:all, :order => 'name')    
  end
end
