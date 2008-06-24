class ReviewMappingController < ApplicationController
  auto_complete_for :user, :name
  
  def auto_complete_for_user_name       
    mapping = ReviewMapping.find(session[:mapping_id])
    @users = User.find_by_sql('SELECT * FROM `users` WHERE `name` like \''+params[:user][:name]+'%\' and `id` IN (SELECT user_id FROM `participants` WHERE `assignment_id` = '+mapping.assignment_id.to_s+')')
    
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end
  
  def add_reviewer
    assignment = Assignment.find(params[:assignment_id])        
    reviewer = User.find_by_name(params[:user][:name])
    if reviewer != nil && assignment != nil 
       if assignment.team_assignment
        mapping = ReviewMapping.create(:team_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
       else
        mapping = ReviewMapping.create(:author_id => params[:contributor_id], :reviewer_id => reviewer.id, :assignment_id => assignment.id, :round => 0)
      end
      mapping.save
    end   
          
    redirect_to :action => 'list_reviewers', :assignment_id => assignment.id, :id => params[:contributor_id]    
  end
  
  def add_rofreviewer    
    reviewmapping = ReviewMapping.find(params[:id])
    rofreviewer = User.find_by_name(params[:user][:name])
    rofr = ReviewOfReviewMapping.create(:review_mapping_id => reviewmapping.id,
                                        :review_reviewer_id => rofreviewer.id)
   
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
    rescue
      flash[:error] = "A delete action failed." + $! 
    end
    redirect_to :action => 'list_reviewers', :assignment_id => assignment.id, :id => contributor.id
  end
  
  def delete_rofreviewer
    mapping = ReviewOfReviewMapping.find(params[:id])
    revmapid = mapping.review_mapping_id
    mapping.delete
    
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
      @items = Team.find_by_sql('select * from `teams` where `assignment_id` = '+@assignment.id.to_s)
    else
      @items = User.find_by_sql('select * from `users` where id in (select `user_id` from `participants` where `assignment_id` = '+@assignment.id.to_s+')')
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
