class ReviewMappingController < ApplicationController
  auto_complete_for :user, :name
  
  def auto_complete_for_user_name           
    query = "select users.* from users, participants"
    query = query + " where participants.type = 'AssignmentParticipant'"
    query = query + " and users.name like '"+params[:user][:name]+"%'"
    query = query + " and users.id = participants.user_id"
    query = query + " and participants.parent_id = "+session[:mapping][:assignment].id.to_s
    query = query + " and participants.parent_id <> "+session[:mapping][:contributor].id.to_s
    query = query + " order by users.name"
   @users = User.find_by_sql(query)
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  
  def add_reviewer
    assignment = Assignment.find(params[:assignment_id])        
    reviewer = User.find_by_name(params[:user][:name])
    if reviewer != nil && assignment != nil  
       if AssignmentParticipant.find_by_parent_id_and_user_id(assignment.id,reviewer.id) == nil
         AssignmentParticipant.create(:parent_id => assignment.id, :user_id => reviewer.id)
       end       
       if assignment.team_assignment
        exists = ReviewMapping.find(:first, :conditions => ['team_id = ? and reviewer_id = ? and assignment_id = ?',params[:contributor_id],reviewer.id,assignment.id])
        if exists == nil
           mapping = ReviewMapping.create(:team_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
        else
          flash[:note] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      else
        exists = ReviewMapping.find(:first, :conditions => ['author_id = ? and reviewer_id = ? and assignment_id = ?',params[:contributor_id],reviewer.id,assignment.id])
        if exists == nil
           mapping = ReviewMapping.create(:author_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
        else
           flash[:note] = "The reviewer, \""+reviewer.name+"\", is already assigned to this contributor."
        end
      end
      if mapping
        mapping.save
      end
    end   
          
    redirect_to :action => 'list_reviewers', :assignment_id => assignment.id, :id => params[:contributor_id]    
  end
  
  def add_rofreviewer    
    reviewmapping = ReviewMapping.find(params[:id])
    rofreviewer = User.find_by_name(params[:user][:name])
    ReviewOfReviewMapping.create(:review_mapping_id => reviewmapping.id,
                                 :review_reviewer_id => rofreviewer.id,                          
                                 :reviewer_id => reviewmapping.reviewer_id
                                 )
   
    redirect_to :action => 'list_rofreviewers', :id => reviewmapping.id                                            
  end  
  
  def list_reviewers        
    @assignment = Assignment.find(params[:assignment_id])
    if @assignment.team_assignment
      @contributor = Team.find(params[:id])
      query = 'team_id = ? and assignment_id = ?'
    else
      @contributor = User.find(params[:id])
      query = 'author_id = ? and assignment_id = ?'
    end
    @items = ReviewMapping.find(:all, :conditions => [query,@contributor.id,@assignment.id])   
  end
  
  def list_rofreviewers    
    @reviewmapping = ReviewMapping.find(params[:id])
    @assignment = Assignment.find(@reviewmapping.assignment_id)
    @items = ReviewOfReviewMapping.find(:all, :conditions => ['review_mapping_id = ?',@reviewmapping.id])
  end  
  
  def delete_all_reviewers    
    mappings = ReviewMapping.get_mappings(params[:assignment_id],params[:id]) 
    mappings.each{ 
       |mapping|
       begin
         mapping.delete
       rescue
         flash[:error] = "A delete action failed." + $!
       end
    }
    if Assignment.find(params[:assignment_id]).team_assignment
      contributor = Team.find(params[:id])
    else
      contributor = User.find(params[:id])
    end
    flash[:note] = "All review mappings for "+contributor.get_author_name+" have been deleted."
    redirect_to :action => 'list_mappings', :id => params[:assignment_id]
  end
  
  def delete_reviewer
    mapping = ReviewMapping.find(params[:id]) 
    assignment = Assignment.find(mapping.assignment_id)
    if assignment.team_assignment
      contributor = Team.find(mapping.team_id)
    else
      contributor = User.find(mapping.author_id)
    end
    begin
      mapping.delete
      flash[:note] = "All review mappings for "+contributor.get_author_name+" and "+mapping.reviewer.name+" have been deleted."        
    rescue      
      flash[:error] = "A delete action failed." + $! 
    end
    redirect_to :action => 'list_reviewers', :assignment_id => assignment.id, :id => contributor.id
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
  
  def list_mappings
    @assignment = Assignment.find(params[:id])
        
    if @assignment.team_assignment
      @items = AssignmentTeam.find_by_sql('select * from `teams` where `parent_id` = '+@assignment.id.to_s)
    else
      @items = User.find_by_sql('select * from `users` where id in (select `user_id` from `participants` where `parent_id` = '+@assignment.id.to_s+')')
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
        redirect_to :action => 'list', :id => @assignment.id
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
