class TreeDisplayController < ApplicationController
  helper :application
  
  # direct access to questionnaires
  def goto_questionnaires
    node_object = TreeFolder.find_by_name('Questionnaires')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  # direct access to review rubrics
  def goto_review_rubrics
    node_object = TreeFolder.find_by_name('Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to metareview rubrics
  def goto_metareview_rubrics
    node_object = TreeFolder.find_by_name('Metareview')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to teammate review rubrics
  def goto_teammatereview_rubrics
    node_object = TreeFolder.find_by_name('Teammate Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to author feedbacks
  def goto_author_feedbacks
    node_object = TreeFolder.find_by_name('Author Feedback')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to global survey
  def goto_global_survey
    node_object = TreeFolder.find_by_name('Global Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to surveys
  def goto_surveys
    node_object = TreeFolder.find_by_name('Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to course evaluations
  def goto_course_evaluations
    node_object = TreeFolder.find_by_name('Course Evaluation')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end    
  
  # direct access to courses
  def goto_courses
    node_object = TreeFolder.find_by_name('Courses')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end
  
  # direct access to assignments
  def goto_assignments
    node_object = TreeFolder.find_by_name('Assignments')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list
    display = params[:display] || session[:display]
    if display
      @sortvar = display[:sortvar]
      @sortorder = display[:sortorder]
      if display[:check] == "1"
        @show = nil
      else
        @show = true
      end
    else
      @show = true
    end
    
    if @sortvar == nil
      @sortvar = 'created_at'
    end
    if @sortorder == nil
      @sortorder = 'desc'
    end
        
    if session[:root]
      @root_node = Node.find(session[:root])
      @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show)
    else
      @child_nodes = FolderNode.get()
    end    
  end   
  
  def drill
    session[:root] = params[:root]
    redirect_to :controller => 'tree_display', :action => 'list'
  end
end
