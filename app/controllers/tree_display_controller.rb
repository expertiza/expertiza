require 'json'

class TreeDisplayController < ApplicationController
  helper :application
  skip_before_action :verify_authenticity_token, only: [:get_children_node_ng, :get_children_node_2_ng]

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
    angularParams = {}
    angularParams[:search] = @search
    angularParams[:show] = @show
    angularParams[:child_nodes] = @child_nodes
    angularParams[:sortvar] = @sortvar
    angularParams[:sortorder] = @sortorder
    angularParams[:user_id] = session[:user].id
    angularParams[:nodeType] = 'FolderNode'
    @angularParamsJSON = angularParams.to_json

  end

  def get_children_node_ng
    logger.warn params
    if params[:angularParams][:child_nodes].is_a? String
      childNodes = JSON.parse(params[:angularParams][:child_nodes])
    else
      childNodes = params[:angularParams][:child_nodes]
    end
    tmpRes = {}
    res = {}
    for node in childNodes
      fnode = eval(params[:angularParams][:nodeType]).new

      for a in node
        fnode[a[0]] = a[1]
      end

      # fnode is the parent node
      # ch_nodes are childrens
      ch_nodes = fnode.get_children(params[:angularParams][:sortvar], 
                                 params[:angularParams][:sortorder],
                                 params[:angularParams][:user_id].to_i, 
                                 params[:angularParams][:show], 
                                 params[:angularParams][:search])
      tmpRes[fnode.get_name] = ch_nodes

      # cnode = fnode.get_children("created_at", "desc", 2, nil, nil)

    end

    for nodeType in tmpRes.keys
      res[nodeType] =  Array.new
      logger.warn res[nodeType].class

      for node in tmpRes[nodeType]
        tmpObject = {}
        tmpObject["nodeinfo"] = node
        tmpObject["name"] = node.get_name

        if nodeType == 'Courses' || nodeType == "Assignments"
          tmpObject["directory"] = node.get_directory
          tmpObject["creation_date"] = node.get_creation_date
          tmpObject["updated_date"] = node.get_modified_date
        end
        res[nodeType] << tmpObject
      end

    end

    respond_to do |format|
      format.html {render json: res}
    end
  end

  def get_children_node_2_ng
    if params[:angularParams][:child_nodes].is_a? String
      childNodes = JSON.parse(params[:angularParams][:child_nodes])
    else
      childNodes = params[:angularParams][:child_nodes]
    end
    tmpRes = {}
    res = []
    fnode = eval(params[:angularParams][:nodeType]).new
    childNodes.each do |key, value|
      fnode[key] = value
    end

    ch_nodes = fnode.get_children(params[:angularParams][:sortvar], 
                                 params[:angularParams][:sortorder],
                                 params[:angularParams][:user_id].to_i, 
                                 params[:angularParams][:show], 
                                 params[:angularParams][:search])
    tmpRes = ch_nodes
    if tmpRes
      # logger.warn tmpRes.inspect
      for child in tmpRes
        nodeType = child.type
        res2 = {}
        res2["nodeinfo"] = child
        res2["name"] = child.get_name
        res2["key"] = params[:angularParams][:key]
        logger.warn res2["key"]
        logger.warn res2["name"]

        if nodeType == 'CourseNode' || nodeType == "AssignmentNode"
          res2["directory"] = child.get_directory
          res2["creation_date"] = child.get_creation_date
          res2["updated_date"] = child.get_modified_date
        end
        res << res2
      end
    end

    logger.warn res

    respond_to do |format|
      format.html {render json: res}
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
