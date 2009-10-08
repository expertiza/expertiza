class ReviewMappingController < ApplicationController
  auto_complete_for :user, :name
  
  def auto_complete_for_user_name           
    query = "select users.* from users, participants"
    query = query + " where participants.type = 'AssignmentParticipant'"
    query = query + " and users.name like '"+params[:user][:name]+"%'"
    query = query + " and users.id = participants.user_id"    
    query = query + " and participants.parent_id <> "+session[:mapping][:contributor].id.to_s
    query = query + " order by users.name"
   @users = User.find_by_sql(query)
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  
  def select_reviewer
    author = params[:id]
    if author.class == AssignmentTeam  
      @contributor = AssignmentTeam.find(author)
    else
      @contributor = AssignmentParticipant.find(author)      
    end
  end
  
  def select_metareviewer
    @mapping = ReviewMapping.find(params[:id])    
  end  
  
  def add_reviewer
    assignment = Assignment.find(params[:assignment_id])        
    reviewer = User.find_by_name(params[:user][:name])    
    if reviewer != nil && assignment != nil  
       #if AssignmentParticipant.find_by_parent_id_and_user_id(assignment.id,reviewer.id) == nil
       #  AssignmentParticipant.create(:parent_id => assignment.id, :user_id => reviewer.id)
       #end       
       if assignment.team_assignment
        exists = ReviewMapping.find(:first, :conditions => ['team_id = ? and reviewer_id = ? and assignment_id = ?',params[:contributor_id],reviewer.id,assignment.id])
        if exists == nil
           mapping = ReviewMapping.create(:team_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
        else
          flash[:error] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      else
        exists = ReviewMapping.find(:first, :conditions => ['author_id = ? and reviewer_id = ? and assignment_id = ?',params[:contributor_id],reviewer.id,assignment.id])
        if exists == nil
           mapping = ReviewMapping.create(:author_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
        else
           flash[:error] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      end
      if mapping
        mapping.save
      end     
    else
      flash[:error] = "Something didn't work"
    end
    redirect_to :action => 'list_mappings', :id => assignment.id    
  end
  
  def add_metareviewer    
    reviewmapping = ReviewMapping.find(params[:id])
    rofreviewer = User.find_by_name(params[:user][:name])
    include = params[:options][:include]
    puts "*******************"
    puts include
    if include == "true"
      pExist = AssignmentParticipant.find_by_user_id_and_parent_id(rofreviewer.id,reviewmapping.assignment_id)
      if pExist == nil
        AssignmentParticipant.create(:user_id => rofreviewer.id,
                                     :parent_id => reviewmapping.assignment_id)
      end
    end
    exists = ReviewOfReviewMapping.find(:first, :conditions => ['review_mapping_id = ? and review_reviewer_id = ?',reviewmapping.id,rofreviewer.id])
    if exists == nil
        ReviewOfReviewMapping.create(:review_mapping_id => reviewmapping.id,                        
                                     :reviewer_id => rofreviewer.id
                                    )
    else
       flash[:error] = "The metareviewer, \""+rofreviewer.name+"\", is already assigned to this reviewer."
    end
   
    redirect_to :action => 'list_mappings', :id => reviewmapping.assignment_id                                            
  end  
  
 
  def delete_all_reviewers_and_metareviewers
    mappings = ReviewMapping.find_all_by_assignment_id(params[:id])
    ReviewMappingHelper::delete_mappings(mappings,flash)
    redirect_to :action => 'list_mappings', :id => params[:id]   
  end  
  
  def delete_all_reviewers  
    assignment = Assignment.find(params[:assignment])
   
    if assignment.team_assignment
      contributor = AssignmentTeam.find(params[:id])
      assignment_id = contributor.parent_id
    else
      participant = AssignmentParticipant.find(params[:id])
      assignment_id = participant.parent_id
      contributor = User.find(participant.user_id)
    end
    assignment = Assignment.find(assignment_id)

    
    mappings = ReviewMapping.get_mappings(assignment.id,contributor.id)
    ReviewMappingHelper::delete_mappings(mappings,flash,contributor)
    redirect_to :action => 'list_mappings', :id => assignment_id 
  end
  

 
  
  def delete_all_metareviewers    
    mapping = ReviewMapping.find(params[:id])    
    assignment_id = mapping.assignment_id
    
    title = "A delete action failed:<br/>"
    msg = ""
    
    rmappings = ReviewOfReviewMapping.find_all_by_review_mapping_id(mapping.id)
    rmappings.each{ 
       |rmapping|
       begin
         rmapping.delete
       rescue
         msg += "&nbsp;&nbsp;&nbsp;" + $! + "<a href='/review_mapping/delete_metareview/"+rmapping.id.to_s+"'>Delete these metareviews</a>?<br/>"
       end
    }
    if msg.length > 0
      title += msg
      flash[:error] = title      
    else
      flash[:note] = "All metareview mappings for contributor, \""+rmapping.review_mapping.reviewer.name+"\", and reviewer, \""+rmapping.reviewer.name+"\", have been deleted."
      
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end  
      
  def delete_participant
    participant = AssignmentParticipant.find(params[:id])
    assignment_id = participant.parent_id
    contributor = User.find(participant.user_id)

    title = "A delete action failed:<br/>"
    msg = ""
    
    mappings = ReviewMapping.get_mappings(assignment_id,contributor.id)
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
    else
      participant.delete
      flash[:note] = "All review mappings for \""+contributor.name+"\" have been deleted."      
    end             
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_reviewer
    mapping = ReviewMapping.find(params[:id]) 
    assignment_id = mapping.assignment_id
    if mapping.assignment.team_assignment
      contributor = Team.find(mapping.team_id)
    else
      contributor = User.find(mapping.author_id)
    end
    begin
      mapping.delete
      flash[:note] = "The review mapping for \""+contributor.name+"\" and \""+mapping.reviewer.name+"\" have been deleted."        
    rescue      
      flash[:error] = "A delete action failed.<br/>&nbsp;&nbsp;&nbsp;" + $! + "<a href='/review_mapping/delete_review/"+mapping.id.to_s+"'>Delete these reviews</a>?"     
    end
    redirect_to :action => 'list_mappings', :id => assignment_id
  end
  
  def delete_metareviewer
    mapping = ReviewOfReviewMapping.find(params[:id])
    assignment_id = mapping.review_mapping.assignment_id
    flash[:note] = "The metareview mapping for "+mapping.review_mapping.reviewer.name+" and "+mapping.reviewer.name+" have been deleted."
    
    begin 
      mapping.delete
    rescue
      flash[:error] = "A delete action failed.<br/>&nbsp;&nbsp;&nbsp;" + $! + "<a href='/review_mapping/delete_metareview/"+mapping.id.to_s+"'>Delete these metareviews</a>?"     
    end
    
    redirect_to :action => 'list_mappings', :id => assignment_id
  end

  
  def delete_review
    mapping = ReviewMapping.find(params[:id])
    review = Review.find_by_review_mapping_id(mapping.id)
    review.delete
    mapping.delete
    assignment = Assignment.find(mapping.assignment_id)
    redirect_to :action => 'list_mappings', :id => assignment.id
  end
  
  def delete_metareview
    mapping = ReviewOfReviewMapping.find(params[:id])
    assignment_id = mapping.review_mapping.assignment_id
    metareview = ReviewOfReview.find_by_review_of_review_mapping_id(mapping.id)
    metareview.delete
    mapping.delete
    redirect_to :action => 'list_mappings', :id => assignment.id
  end
  
  def delete_rofreviewer
    mapping = ReviewOfReviewMapping.find(params[:id])
    revmapid = mapping.review_mapping_id
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
      if @assignment.team_assignment
        review_mappings = ReviewMapping.find_all_by_assignment_id_and_team_id(@assignment.id,contrib.id)
      else
        review_mappings = ReviewMapping.find_all_by_assignment_id_and_author_id(@assignment.id,contrib.user_id)
      end
      puts "********************"
      puts review_mappings.size
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
        metareview_mappings = ReviewOfReviewMapping.find_all_by_review_mapping_id(review_map.id)
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
  
  def list_mappings
    @assignment = Assignment.find(params[:id])       
    if @assignment.team_assignment
      @items = AssignmentTeam.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.name <=> b.name}
    else
      @items = AssignmentParticipant.find_all_by_parent_id(@assignment.id) 
      @items.sort!{|a,b| a.fullname <=> b.fullname}
    end
  end
  
  def save_reviewer_mappings
    @assignment = Assignment.find(params[:id])
    @assignment.review_strategy_id = 1
    @assignment.mapping_strategy_id = 1
    @assignment.save     
   
    mapping_strategy = {}
    params[:selection].each{|a|
      if a[0] =~ /^m_/
        mapping_strategy[a[0]] = a[1]
      end
    }
    
    if @assignment.update_attributes(params[:assignment])
      begin
        ReviewMapping.assign_reviewers(@assignment.id, @assignment.num_reviews, @assignment.num_review_of_reviews, mapping_strategy)        
      rescue
        flash[:error] = "Reviewer assignment failed. Cause: " + $!
      ensure
        redirect_to :action => 'list_mappings', :id => @assignment.id
      end
    else
      @wiki_types = WikiType.find_all
      render :action => 'edit'
    end    
  end  
  
  
  def select_mapping
    @assignment = Assignment.find(params[:id])
    @review_strategies = ReviewStrategy.find(:all, :order => 'name')
    @mapping_strategies = MappingStrategy.find(:all, :order => 'name')    
  end
end
