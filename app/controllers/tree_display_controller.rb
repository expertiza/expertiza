class TreeDisplayController < ApplicationController
  helper :application

  def action_allowed?
    true
  end

  def goto_controller(name_parameter)
    node_object = TreeFolder.find_by(name: name_parameter)
    session[:root] = FolderNode.find_by(node_object_id: node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  # direct access to questionnaires
  def goto_questionnaires
    goto_controller('Questionnaires')
  end

  # direct access to review rubrics
  def goto_review_rubrics
    goto_controller('Review')
  end

  # direct access to metareview rubrics
  def goto_metareview_rubrics
    goto_controller('Metareview')
  end

  # direct access to teammate review rubrics
  def goto_teammatereview_rubrics
    goto_controller('Teammate Review')
  end

  # direct access to author feedbacks
  def goto_author_feedbacks
    goto_controller('Author Feedback')
  end

  # direct access to global survey
  def goto_global_survey
    goto_controller('Global Survey')
  end

  # direct access to surveys
  def goto_surveys
    goto_controller('Survey')
  end

  # direct access to course evaluations
  def goto_course_evaluations
    goto_controller('Course Evaluation')
  end

  # direct access to courses
  def goto_courses
    goto_controller('Courses')
  end

  def goto_bookmarkrating_rubrics
    goto_controller('Bookmarkrating')
  end

  # direct access to assignments
  def goto_assignments
    goto_controller('Assignments')
  end

  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list
    redirect_to controller: :student_task, action: :list if current_user.student?
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

  def folder_node_ng
    respond_to do |format|
      format.html { render json: FolderNode.get }
    end
  end

  def child_nodes_from_params(child_nodes)
    if child_nodes.is_a? String
      JSON.parse(child_nodes)
    else
      child_nodes
    end
  end

  def assignments_func(node, tmp_object)
    tmp_object.merge!(
      "course_id" => node.get_course_id,
      "max_team_size" => node.get_max_team_size,
      "is_intelligent" => node.get_is_intelligent,
      "require_quiz" => node.get_require_quiz,
      "allow_suggestions" => node.get_allow_suggestions,
      "has_topic" => SignUpTopic.where(['assignment_id = ?', node.node_object_id]).first ? true : false
    )
  end

  def update_in_ta_course_listing(instructor_id, node, tmp_object)
    tmp_object["private"] = true if session[:user].role.ta? == 'Teaching Assistant' &&
        Ta.get_my_instructors(session[:user].id).include?(instructor_id) &&
        ta_for_current_course?(node)
    # end
  end

  def update_is_available(tmp_object, instructor_id, node)
    tmp_object["is_available"] = is_available(session[:user], instructor_id) || (session[:user].role.ta? &&
        Ta.get_my_instructors(session[:user].id).include?(instructor_id) && ta_for_current_course?(node))
  end

  def update_instructor(tmp_object, instructor_id)
    tmp_object["instructor_id"] = instructor_id
    tmp_object["instructor"] = nil
    tmp_object["instructor"] = User.find(instructor_id).name if instructor_id
  end

  def update_tmp_obj(tmp_object, node)
    tmp_object.merge!(
      "directory" => node.get_directory,
      "creation_date" => node.get_creation_date,
      "updated_date" => node.get_modified_date,
      "private" => node.get_instructor_id == session[:user].id ? true : false
    )
  end

  def courses_assignments_obj(tmp_object, node)
    update_tmp_obj(tmp_object, node)
    # tmpObject["private"] = node.get_private
    instructor_id = node.get_instructor_id
    ## if current user's role is TA for a course, then that course will be listed under his course listing.
    update_in_ta_course_listing(instructor_id, node, tmp_object)
    update_instructor(tmp_object, instructor_id)
    update_is_available(tmp_object, instructor_id, node)
    assignments_func(node, tmp_object) if node_type == "Assignments"
  end

  def res_node_for_child(tmp_res)
    res = {}
    tmp_res.keys.each do |node_type|
      res[node_type] = []
      tmp_res[node_type].each do |node|
        tmp_object = {
          "nodeinfo" => node,
          "name" => node.get_name,
          "type" => node.type
        }
        if node_type == 'Courses' || node_type == "Assignments"
          courses_assignments_obj(tmp_object, node)
        end
        res[node_type] << tmp_object
      end
    end
    res
  end

  def update_fnode_children(fnode, tmp_res)
    # fnode is the parent node
    # ch_nodes are childrens
    ch_nodes = fnode.get_children(nil, nil, session[:user].id, nil, nil)
    tmp_res[fnode.get_name] = ch_nodes
  end

  def init_fnode_update_children(fnode, node, tmp_res)
    node.each do |a|
      fnode[a[0]] = a[1]
    end
    update_fnode_children(fnode, tmp_res)
  end

  # for folder nodes
  def children_node_ng
    child_nodes = child_nodes_from_params(params[:reactParams][:child_nodes])
    tmp_res = {}
    child_nodes.each do |node|
      fnode = Object.const_get(params[:reactParams][:nodeType]).new
      init_fnode_update_children(fnode, node, tmp_res)

      res = res_node_for_child(tmp_res)
      # cnode = fnode.get_children("created_at", "desc", 2, nil, nil)
    end

    respond_to do |format|
      format.html { render json: res }
    end
  end

  def coursenode?(ta_mappings, node)
    ta_mappings.each do |ta_mapping|
      return true if ta_mapping.course_id == node.node_object_id
    end
  end

  def assignmentnode?(ta_mappings, node)
    course_id = Assignment.find(node.node_object_id).course_id
    ta_mappings.each do |ta_mapping|
      return true if ta_mapping.course_id == course_id
    end
  end

  def ta_for_current_course?(node)
    ta_mappings = TaMapping.where(ta_id: session[:user].id)
    if node.type == "CourseNode"
      return true if coursenode?(ta_mappings, node)
    elsif node.type == "AssignmentNode"
      return true if assignmentnode?(ta_mappings, node)
    end
    false
  end

  def available_condition2?(instructor_id, child)
    # instructor created the course, current user is the ta of this course.
    session[:user].role_id == 6 and
        Ta.get_my_instructors(session[:user].id).include?(instructor_id) and ta_for_current_course?(child)
  end

  def available_condition3?(instructor_id)
    # ta created the course, current user is the instructor of this ta.
    instructor_ids = []
    TaMapping.where(ta_id: instructor_id).each {|mapping| instructor_ids << Course.find(mapping.course_id).instructor_id }
    session[:user].role_id == 2 and instructor_ids.include? session[:user].id
  end

  def update_is_available_2(res2, instructor_id, child)
    # current user is the instructor (role can be admin/instructor/ta) of this course. is_available_condition1
    res2["is_available"] = is_available(session[:user], instructor_id) ||
        available_condition2?(instructor_id, child) ||
        available_condition3?(instructor_id)
  end

  def coursenode_assignmentnode(res2, child)
    res2["directory"] = child.get_directory
    instructor_id = child.get_instructor_id
    update_instructor(res2, instructor_id)
    update_is_available_2(res2, instructor_id, child)
    assignments_func(child, res2) if node_type == "AssignmentNode"
  end

  def res_node_for_child_2(tmp_res)
    res = []

    if tmp_res
      tmp_res.each do |child|
        node_type = child.type
        res2 = {
          "nodeinfo" => child,
          "name" => child.get_name,
          "key" => params[:reactParams2][:key],
          "type" => node_type,
          "private" => child.get_private,
          "creation_date" => child.get_creation_date,
          "updated_date" => child.get_modified_date
        }
        if node_type == 'CourseNode' || node_type == "AssignmentNode"
          coursenode_assignmentnode(res2, child)
        end
        res << res2
      end
    end
    res2
  end

  def init_fnode_2(fnode, child_nodes)
    child_nodes.each do |key, value|
      fnode[key] = value
    end
  end

  # for child nodes
  def children_node_2_ng
    child_nodes = child_nodes_from_params(params[:reactParams2][:child_nodes])

    fnode = Object.const_get(params[:reactParams2][:nodeType]).new
    init_fnode_2(fnode, child_nodes)

    ch_nodes = fnode.get_children(nil, nil, session[:user].id, nil, nil)
    tmp_res = ch_nodes
    res = res_node_for_child_2(tmp_res)
    respond_to do |format|
      format.html { render json: res }
    end
  end

  def bridge_to_is_available
    user = session[:user]
    owner_id = params[:owner_id]
    is_available(user, owner_id)
  end

  def session_last_open_tab
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

  def filter_qan(search, qid)
    assignment = Assignment.find_by(name: search)
    if assignment
      assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment.id)
      if assignment_questionnaires
        assignment_questionnaires.each {|q| qid << "#{q.questionnaire_id}+" }
        session[:root] = 1
      end
    end
    qid
  end

  def filter
    qid = 'filter+'
    search = params[:filter_string]
    filter_node = params[:filternode]
    if filter_node == 'QAN'
      qid = filter_qan(search, qid)
    elsif filter_node == 'ACN'
      session[:root] = 2
      qid << search
    end
    qid
  end
end
