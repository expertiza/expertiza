class TreeDisplayController < ApplicationController
  helper :application
  include SecurityHelper
  include AuthorizationHelper

  # Checks controller permissions
  def action_allowed?
    true
  end

  # refactored method to provide direct access to parameters
  # added an argument prevTab for sending the respective tab to be highlighted on homepage
  def goto_controller(name_parameter, prev_tab)
    node_object = TreeFolder.find_by(name: name_parameter)
    session[:root] = FolderNode.find_by(node_object_id: node_object.id).id
    # if we have to highlight a tab, we store this arg. to the last_open_tab elements of session
    session[:last_open_tab] = prev_tab unless prev_tab.nil?
    redirect_to controller: 'tree_display', action: 'list', currCtlr: name_parameter
  end

  def confirm
    @id = params[:id]
    @node_type = params[:nodeType]
  end

  def goto_questionnaires
    goto_controller('Questionnaires', '3')
  end

  def goto_review_rubrics
    goto_controller('Review', '3')
  end

  def goto_metareview_rubrics
    goto_controller('Metareview', '3')
  end

  def goto_teammatereview_rubrics
    goto_controller('Teammate Review', '3')
  end

  def goto_author_feedbacks
    goto_controller('Author Feedback', '3')
  end

  def goto_global_survey
    goto_controller('Global Survey', '3')
  end

  def goto_surveys
    goto_controller('Assignment Survey', '3')
  end

  def goto_course_surveys
    goto_controller('Course Survey', '3')
  end

  def goto_courses
    goto_controller('Courses', '1')
  end

  def goto_bookmarkrating_rubrics
    goto_controller('Bookmarkrating', '3')
  end

  def goto_assignments
    goto_controller('Assignments', '2')
  end

  # Redirects to proper page if user is not an instructor or TA.
  def list
    @currCtlr = params[:currCtlr]
    redirect_to controller: :content_pages, action: :view unless user_logged_in?

    redirect_to controller: :student_task, action: :list if current_user.try(:student?)
  end

  # Returns the contents of each top level folder as a json object.
  def get_folder_contents
    # Get all child nodes associated with a top level folder that the logged in user is authorized
    # to view. Top level folders include Questionaires, Courses, and Assignments.
    folders = {}
    FolderNode.includes(:folder).get.each do |folder_node|
      child_nodes = folder_node.get_children(nil, nil, session[:user].id, nil, nil)
      # Serialize the contents of each node so it can be displayed on the UI
      contents = []
      child_nodes.each do |node|
        contents.push(serialize_folder_to_json(folder_node.get_name, node))
      end

      # Store contents according to the root level folder.
      folders[folder_node.get_name] = contents
    end

    respond_to do |format|
      format.html { render json: folders }
    end
  end

  # Returns the contents of only the specified folder
  def get_specific_folder_contents
    # Get all child nodes associated with a top level folder that the logged in user is authorized
    # to view. Top level folders include Questionaires, Courses, and Assignments.
    folders = {}
    FolderNode.includes(:folder).get.each do |folder_node|
      child_nodes = folder_node.get_children(nil, nil, session[:user].id, nil, nil)
      # Serialize the contents of each node so it can be displayed on the UI
      contents = []
      child_nodes.each do |node|
        contents.push(serialize_folder_to_json(folder_node.get_name, node))
      end

      # Store contents according to the root level folder.
      folders[folder_node.get_name] = contents
    end

    respond_to do |format|
      format.html { render json: folders }
    end
  end

  # for child nodes
  def children_node_ng
    flash[:error] = 'Invalid JSON in the TreeList' unless json_valid? params[:reactParams][:child_nodes]
    child_nodes = child_nodes_from_params(params[:reactParams][:child_nodes])
    tmp_res = {}
    begin
      child_nodes.each do |node|
        initialize_fnode_update_children(params, node, tmp_res)
      end
      flash[:error] = 'Invalid child nodes in the TreeList'
    rescue StandardError
      flash[:warn] = 'StandardError running initialize_fnode_update_children on child_nodes in children_node_ng'
    end

    respond_to do |format|
      format.html { render json: contents }
    end
  end

  # Returns the contents of the Courses and Questionnaire subfolders
  def get_sub_folder_contents
    # Convert the object received in parameters to a FolderNode object.
    folder_node = (params[:reactParams2][:nodeType]).constantize.new
    params[:reactParams2][:child_nodes].each do |key, value|
      folder_node[key] = value
    end

    # Get all of the children in the sub-folder.
    child_nodes = folder_node.get_children(nil, nil, session[:user].id, nil, nil)

    # Serialize the contents of each node so it can be displayed on the UI
    contents = []
    child_nodes.each do |node|
      contents.push(serialize_sub_folder_to_json(node))
    end
    respond_to do |format|
      format.html { render json: contents }
    end
  end

  # # for child nodes
  # def children_node_2_ng
  #   child_nodes = child_nodes_from_params(params[:reactParams2][:child_nodes])
  #   res = get_tmp_res(params, child_nodes)
  #   respond_to do |format|
  #     format.html { render json: res }
  #   end
  # end
  # ^^^ original method for "handleExpandClick"
  # For the questionnaire's handleExpandClick function, it appears that the get_sub_folder_contents method is not capable of returning the data.
  # We fixed the courses by rendering the json properly on the return to the jquery post request from the front-end
  # The assignments tab did not have any data when we used the react debugging extension (i.e. the childNodes attribute was null)
  # From this, we assumed there was no data to display underneath each assignment
  # After debugging, we found that the "nodeType" attribute in the :reactParams field of the post request identifies the type of childNodes to be retrieved (i.e. "courses" or "Questionnaires")
  # We found that a "FolderNode" value for this attribute equates to a questionnaire

  # check if nodetype is coursenode
  def course_node_for_current_ta?(ta_mappings, node)
    ta_mappings.each { |ta_mapping| return true if ta_mapping.course_id == node.node_object_id }
    false
  end

  # check if nodetype is assignmentnode
  def assignment_node_for_current_ta?(ta_mappings, node)
    course_id = Assignment.find(node.node_object_id).course_id
    ta_mappings.each { |ta_mapping| return true if ta_mapping.course_id == course_id }
    false
  end

  # check if user is ta for current course
  def ta_for_current_course?(node)
    ta_mappings = TaMapping.where(ta_id: session[:user].id)
    return course_node_for_current_ta?(ta_mappings, node) if node.is_a? CourseNode
    return assignment_node_for_current_ta?(ta_mappings, node) if node.is_a? AssignmentNode

    false
  end

  # check if current user is ta for instructor
  def is_user_ta?(instructor_id, child)
    # instructor created the course, current user is the ta of this course.
    (session[:user].role_id == 6) &&
      Ta.get_my_instructors(session[:user].id).include?(instructor_id) && ta_for_current_course?(child)
  end

  # check if current user is instructor
  def is_user_instructor?(instructor_id)
    # ta created the course, current user is the instructor of this ta.
    instructor_ids = []
    TaMapping.where(ta_id: instructor_id).each { |mapping| instructor_ids << Course.find(mapping.course_id).instructor_id }
    (session[:user].role_id == 2) && instructor_ids.include?(session[:user].id)
  end

  def update_is_available_2(res2, instructor_id, child)
    # current user is the instructor (role can be admin/instructor/ta) of this course. is_available_condition1
    res2['is_available'] = available?(session[:user], instructor_id) ||
                           is_user_ta?(instructor_id, child) ||
                           is_user_instructor?(instructor_id)
  end

  # attaches assignment nodes to course node of instructor
  def coursenode_assignmentnode(res2, child)
    res2['directory'] = child.get_directory
    instructor_id = child.get_instructor_id
    update_instructor(res2, instructor_id)
    update_is_available_2(res2, instructor_id, child)
    assignments_method(child, res2) if child.type == 'AssignmentNode'
  end

  # getting result nodes for child2. res[] contains all the resultant nodes.
  def res_node_for_child_2(ch_nodes)
    res = []

    if ch_nodes
      ch_nodes.each do |child|
        node_type = child.type
        res2 = {
          'nodeinfo' => child,
          'name' => child.get_name,
          'instructor_id' => child.get_instructor_id, # add instructor id to the payload to make it available in the frontend
          'key' => params[:reactParams2][:key],
          'type' => node_type,
          'private' => child.get_private,
          'creation_date' => child.get_creation_date,
          'updated_date' => child.get_modified_date
        }
        coursenode_assignmentnode(res2, child) if %w[CourseNode AssignmentNode].include? node_type
        res << res2
      end
    end
    res
  end

  # initialising folder node 2
  def initialize_fnode_2(fnode, child_nodes)
    child_nodes.each do |key, value|
      fnode[key] = value
    end

    respond_to do |format|
      format.html { render json: contents }
    end
  end

  # Gets and renders last open tab from session
  def session_last_open_tab
    res = session[:last_open_tab]
    respond_to do |format|
      format.html { render json: res }
    end
  end

  # Sets the last open tab from params
  def set_session_last_open_tab
    session[:last_open_tab] = params[:tab]
    res = session[:last_open_tab]
    respond_to do |format|
      format.html { render json: res }
    end
  end

  # Gets root 'level' of tree and redirects to the list action
  def drill
    session[:root] = params[:root]
    redirect_to controller: 'tree_display', action: 'list'
  end

  private

  # Add assignment attributes to json
  def serialize_assignment_to_json(node, json)
    json.merge!(
      'course_id' => node.get_course_id,
      'max_team_size' => node.get_max_team_size,
      'is_intelligent' => node.get_is_intelligent,
      'require_quiz' => node.get_require_quiz,
      'allow_suggestions' => node.get_allow_suggestions,
      'has_topic' => SignUpTopic.where(['assignment_id = ?', node.node_object_id]).first ? true : false
    )
  end

  # Creates a json object that can be displayed by the UI
  def serialize_folder_to_json(folder_type, node)
    json = {
      'nodeinfo' => node,
      'name' => node.get_name,
      'type' => node.type
    }

    if folder_type == 'Courses' || folder_type == 'Assignments'
      json.merge!(
        'directory' => node.get_directory,
        'creation_date' => node.get_creation_date,
        'updated_date' => node.get_modified_date,
        'institution' => Institution.where(id: node.retrieve_institution_id),
        'private' => course_is_available?(node)
      )
      json['instructor_id'] = node.get_instructor_id
      json['instructor'] = node.get_instructor_id ? User.find(node.get_instructor_id).name(session[:ip]) : nil
      json['is_available'] = course_is_available?(node)
      serialize_assignment_to_json(node, json) if folder_type == 'Assignments'
    end

    json
  end

  # Creates a json object that can be displayed by the UI
  def serialize_sub_folder_to_json(node)
    json = {
      'nodeinfo' => node,
      'name' => node.get_name,
      'type' => node.type,
      'key' => params[:reactParams2][:key],
      'private' => node.get_private,
      'creation_date' => node.get_creation_date,
      'updated_date' => node.get_modified_date
    }
    if (node.type == 'CourseNode') || (node.type == 'AssignmentNode')
      json['directory'] = node.get_directory
      json['instructor_id'] = node.get_instructor_id
      json['instructor'] = node.get_instructor_id ? User.find(node.get_instructor_id).name(session[:ip]) : nil
      json['is_available'] = course_is_available?(node)
      serialize_assignment_to_json(node, json) if node.type == 'AssignmentNode'
    end

    json
  end

  # Checks if the user is the instructor for the course or assignment node provided.
  # Note: Admin and super admin users are considered instructors for all courses.
  def instructor_for_course?(node)
    available?(session[:user], node.get_instructor_id)
  end

  # Checks if the user is a TA for the course or assignment node provided.
  def ta_for_course?(node)
    ta_mappings = TaMapping.where(ta_id: session[:user].id)
    course_id = node.is_a?(CourseNode) ? node.node_object_id : Assignment.find(node.node_object_id).course_id
    ta_mappings.any? { |ta_mapping| ta_mapping.course_id == course_id }
  end

  # Check if the provided course or assignment node is available to the logged in user.
  # Instructors and TA's have access to courses, not individual assignments. It doesn't matter
  # which node is passed in, we only about course access.
  def course_is_available?(node)
    instructor_for_course?(node) || ta_for_course?(node)
  end
end
