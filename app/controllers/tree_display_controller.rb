class TreeDisplayController < ApplicationController
  helper :application

  def action_allowed?
    true
  end

  # direct access to questionnaires
  def goto_questionnaires
    node_object = TreeFolder.find_by_name('Questionnaires')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to review rubrics
  def goto_review_rubrics
    node_object = TreeFolder.find_by_name('Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to metareview rubrics
  def goto_metareview_rubrics
    node_object = TreeFolder.find_by_name('Metareview')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to teammate review rubrics
  def goto_teammatereview_rubrics
    node_object = TreeFolder.find_by_name('Teammate Review')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to author feedbacks
  def goto_author_feedbacks
    node_object = TreeFolder.find_by_name('Author Feedback')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to global survey
  def goto_global_survey
    node_object = TreeFolder.find_by_name('Global Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to surveys
  def goto_surveys
    node_object = TreeFolder.find_by_name('Survey')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to course evaluations
  def goto_course_evaluations
    node_object = TreeFolder.find_by_name('Course Evaluation')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to courses
  def goto_courses
    node_object = TreeFolder.find_by_name('Courses')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  def goto_bookmarkrating_rubrics
    node_object = TreeFolder.find_by_name('Bookmarkrating')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to assignments
  def goto_assignments
    node_object = TreeFolder.find_by_name('Assignments')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list
    redirect_to controller: :content_pages, action: :view if current_user.nil?
    redirect_to controller: :student_task, action: :list if current_user.try(:student?)
    # if params[:commit] == 'Search'
    #   search_node_root = {'Q' => 1, 'C' => 2, 'A' => 3}

    #   if params[:search_string]
    #     search_node = params[:searchnode]
    #     session[:root] = search_node_root[search_node]
    #     search_string = params[:search_string]
    #   else
    #     search_string = nil
    #   end
    # else
    #   search_string = nil
    # end

    # search_string = filter if params[:commit] == 'Filter'
    # search_string = nil if params[:commit] == 'Reset'

    # @search = search_string

    # display = params[:display] #|| session[:display]
    # if display
    #   @sortvar = display[:sortvar]
    #   @sortorder = display[:sortorder]
    # end

    # @sortvar ||= 'created_at'
    # @sortorder ||= 'desc'

    # if session[:root]
    #   @root_node = Node.find(session[:root])
    #   @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show,nil,@search)
    # else
    # child_nodes = FolderNode.get()
    # end
    # @reactjsParams = {}
    # @reactjsParams[:nodeType] = 'FolderNode'
    # @reactjsParams[:child_nodes] = child_nodes
  end

  def get_folder_node_ng
    respond_to do |format|
      format.html { render json: FolderNode.get }
    end
  end

  # for folder nodes
  def get_children_node_ng
    childNodes = {}
    childNodes = if params[:reactParams][:child_nodes].is_a? String
                   JSON.parse(params[:reactParams][:child_nodes])
                 else
                   params[:reactParams][:child_nodes]
                 end
    tmpRes = {}
    res = {}
    for node in childNodes
      fnode = eval(params[:reactParams][:nodeType]).new

      for a in node
        fnode[a[0]] = a[1]
      end

      # fnode is the parent node
      # ch_nodes are childrens
      ch_nodes = fnode.get_children(nil, nil, session[:user].id, nil, nil)
      tmpRes[fnode.get_name] = ch_nodes

      # cnode = fnode.get_children("created_at", "desc", 2, nil, nil)

    end

    for nodeType in tmpRes.keys
      res[nodeType] = []

      for node in tmpRes[nodeType]
        tmpObject = {}
        tmpObject["nodeinfo"] = node
        tmpObject["name"] = node.get_name
        tmpObject["type"] = node.type

        if nodeType == 'Courses' || nodeType == "Assignments"
          tmpObject["directory"] = node.get_directory
          tmpObject["creation_date"] = node.get_creation_date
          tmpObject["updated_date"] = node.get_modified_date
          # tmpObject["private"] = node.get_private
          tmpObject["private"] = node.get_instructor_id === session[:user].id ? true : false
          instructor_id = node.get_instructor_id
          ## if current user's role is TA for a course, then that course will be listed under his course listing.
          if session[:user].role.ta? == 'Teaching Assistant' && Ta.get_my_instructors(session[:user].id).include?(instructor_id) && ta_for_current_course?(node)
            tmpObject["private"] = true
          end

          tmpObject["instructor_id"] = instructor_id
          tmpObject["instructor"] = unless instructor_id.nil?
                                      User.find(instructor_id).name
                                    end

          tmpObject["is_available"] = is_available(session[:user], instructor_id) || (session[:user].role.ta? && Ta.get_my_instructors(session[:user].id).include?(instructor_id) && ta_for_current_course?(node))
          if nodeType == "Assignments"
            tmpObject["course_id"] = node.get_course_id
            tmpObject["max_team_size"] = node.get_max_team_size
            tmpObject["is_intelligent"] = node.get_is_intelligent
            tmpObject["require_quiz"] = node.get_require_quiz
            tmpObject["allow_suggestions"] = node.get_allow_suggestions
            tmpObject["has_topic"] = SignUpTopic.where(['assignment_id = ?', node.node_object_id]).first ? true : false
          end
        end
        res[nodeType] << tmpObject
      end

    end

    respond_to do |format|
      format.html { render json: res }
    end
  end

  def ta_for_current_course?(node)
    ta_mappings = TaMapping.where(ta_id: session[:user].id)
    if node.type == "CourseNode"
      ta_mappings.each do |ta_mapping|
        return true if ta_mapping.course_id == node.node_object_id
      end
    elsif node.type == "AssignmentNode"
      course_id = Assignment.find(node.node_object_id).course_id
      ta_mappings.each do |ta_mapping|
        return true if ta_mapping.course_id == course_id
      end
    end
    false
  end

  # for child nodes
  def get_children_node_2_ng
    childNodes = {}
    childNodes = if params[:reactParams2][:child_nodes].is_a? String
                   JSON.parse(params[:reactParams2][:child_nodes])
                 else
                   params[:reactParams2][:child_nodes]
                 end
    tmpRes = {}
    res = []
    fnode = eval(params[:reactParams2][:nodeType]).new
    childNodes.each do |key, value|
      fnode[key] = value
    end

    ch_nodes = fnode.get_children(nil, nil, session[:user].id, nil, nil)
    tmpRes = ch_nodes
    if tmpRes
      for child in tmpRes
        nodeType = child.type
        res2 = {}
        res2["nodeinfo"] = child
        res2["name"] = child.get_name
        res2["key"] = params[:reactParams2][:key]
        res2["type"] = nodeType

        res2["private"] = child.get_private
        res2["creation_date"] = child.get_creation_date
        res2["updated_date"] = child.get_modified_date
        if nodeType == 'CourseNode' || nodeType == "AssignmentNode"
          res2["directory"] = child.get_directory
          instructor_id = child.get_instructor_id
          res2["instructor_id"] = instructor_id
          res2["instructor"] = unless instructor_id.nil?
                                 User.find(instructor_id).name
                               end

          # current user is the instructor (role can be admin/instructor/ta) of this course.
          available_condition_1 = is_available(session[:user], instructor_id)

          # instructor created the course, current user is the ta of this course.
          available_condition_2 = session[:user].role_id == 6 and Ta.get_my_instructors(session[:user].id).include?(instructor_id) and ta_for_current_course?(child)

          # ta created the course, current user is the instructor of this ta.
          instructor_ids = []
          TaMapping.where(ta_id: instructor_id).each {|mapping| instructor_ids << Course.find(mapping.course_id).instructor_id }
          available_condition_3 = session[:user].role_id == 2 and instructor_ids.include? session[:user].id

          res2["is_available"] = available_condition_1 || available_condition_2 || available_condition_3

          if nodeType == "AssignmentNode"
            res2["course_id"] = child.get_course_id
            res2["max_team_size"] = child.get_max_team_size
            res2["is_intelligent"] = child.get_is_intelligent
            res2["require_quiz"] = child.get_require_quiz
            res2["allow_suggestions"] = child.get_allow_suggestions
            res2["has_topic"] = SignUpTopic.where(['assignment_id = ?', child.node_object_id]).first ? true : false
          end
        end
        res << res2
      end
    end

    respond_to do |format|
      format.html { render json: res }
    end
  end

  def bridge_to_is_available
    user = session[:user]
    owner_id = params[:owner_id]
    is_available(user, owner_id)
  end

  def get_session_last_open_tab
    res = session[:last_open_tab]
    respond_to do |format|
      format.html { render json: res }
    end
  end

  def set_session_last_open_tab
    session[:last_open_tab] = params[:tab]
    res = session[:last_open_tab]
    respond_to do |format|
      format.html { render json: res }
    end
  end

  def drill
    session[:root] = params[:root]
    redirect_to controller: 'tree_display', action: 'list'
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
          assignment_questionnaires.each {|q| qid << "#{q.questionnaire_id}+" }
          session[:root] = 1
        end
      end
    elsif filter_node == 'ACN'
      session[:root] = 2
      qid << search
    end
    qid
  end
  end
