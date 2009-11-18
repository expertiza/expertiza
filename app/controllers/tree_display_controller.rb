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
    node_object = QuestionnaireType.find_by_name('Review')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to metareview rubrics
  def goto_metareview_rubrics
    node_object = QuestionnaireType.find_by_name('Metareview')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to teammate review rubrics
  def goto_teammatereview_rubrics
    node_object = QuestionnaireType.find_by_name('Teammate Review')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end   
  
  # direct access to author feedbacks
  def goto_author_feedbacks
    node_object = QuestionnaireType.find_by_name('Author Feedback')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to global survey
  def goto_global_survey
    node_object = QuestionnaireType.find_by_name('Global Survey')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to surveys
  def goto_surveys
    node_object = QuestionnaireType.find_by_name('Survey')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end  
  
  # direct access to course evaluations
  def goto_course_evaluations
    node_object = QuestionnaireType.find_by_name('Course Evaluation')
    session[:root] = QuestionnaireTypeNode.find_by_node_object_id(node_object.id).id
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
    if session[:display]      
      @sortvar = session[:display][:sortvar]
      @sortorder = session[:display][:sortorder]
      if session[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
    end
    if params[:display]      
      @sortvar = params[:display][:sortvar]
      @sortorder = params[:display][:sortorder] 
      if params[:display][:check] == "1"
        @show = nil
      else
        @show = true
      end
      session[:display] = params[:display]      
    end
  
    if session[:display].nil? and params[:display].nil?
      @show = true
    end
    
    if @sortvar == nil
      @sortvar = 'name'
    end
    if @sortorder == nil
      @sortorder = 'asc'
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
