class TreeDisplayController < ApplicationController
  helper :application

  def action_allowed?
    true
  end

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

  def goto_bookmarkrating_rubrics
    node_object = TreeFolder.find_by_name('Bookmarkrating')
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
    redirect_to controller: :student_task, action: :list if current_user.student?
    if params[:commit] == 'Search'
      search_node_root = {'Q' => 1, 'C' => 2, 'A' => 3}

      if params[:search_string]
        search_node = params[:searchnode]
        session[:root] = search_node_root[search_node]
        search_string = params[:search_string]
      else
        search_string = nil
      end
    else
      search_string = nil
    end

    search_string = filter if params[:commit] == 'Filter'
    search_string = nil if params[:commit] == 'Reset'

    @search = search_string

    display = params[:display] #|| session[:display]
    if display
      @sortvar = display[:sortvar]
      @sortorder = display[:sortorder]
    end

    @sortvar ||= 'created_at'
    @sortorder ||= 'desc'

    if session[:root]
      @root_node = Node.find(session[:root])
      @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show,nil,@search)
    else
      @child_nodes = FolderNode.get()
    end
  end

  def drill
    session[:root] = params[:root]
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def filter
    search = params[:filter_string]
    filter_node = params[:filternode]
    qid = 'filter+'

    if filter_node == 'QAN'
      assignment = Assignment.find_by_name(search)
      if assignment
        assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment.id)
        if assignment_questionnaires
          assignment_questionnaires.each { |q|  qid << "#{q.questionnaire_id.to_s}+" }
          session[:root] = 1
        end
      end
    elsif filter_node == 'ACN'
      session[:root] = 2
      qid <<  search
    end
    return qid
  end

  end
