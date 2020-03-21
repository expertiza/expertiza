class TreeDisplayController < ApplicationController
  helper :application
  include SecurityHelper

  def action_allowed?
    true
  end

  def confirm
    @id = params[:id]
    @node_type = params[:nodeType]
  end

  # The goto_ methods listed below are used to traverse the menu system. It is hard to tell exactly
  # where they are called from, but at least some (if not all) are necessary.
  # These functions feel like they have potential to be moved to another controller.
  def goto_controller(name_parameter)
    node_object = TreeFolder.find_by(name: name_parameter)
    session[:root] = FolderNode.find_by(node_object_id: node_object.id).id
    redirect_to controller: 'tree_display', action: 'list'
  end

  def goto_questionnaires; goto_controller('Questionnaires') end
  def goto_review_rubrics; goto_controller('Review') end
  def goto_metareview_rubrics; goto_controller('Metareview') end
  def goto_teammatereview_rubrics; goto_controller('Teammate Review') end
  def goto_author_feedbacks; goto_controller('Author Feedback') end
  def goto_global_survey; goto_controller('Global Survey') end
  def goto_surveys; goto_controller('Assignment Survey') end
  def goto_course_surveys; goto_controller('Course Survey') end
  def goto_courses; goto_controller('Courses') end
  def goto_bookmarkrating_rubrics; goto_controller('Bookmarkrating') end
  def goto_assignments; goto_controller('Assignments') end

  # Redirects to proper page if user is not an instructor or TA.
  def list
    redirect_to controller: :content_pages, action: :view if current_user.nil?
    redirect_to controller: :student_task, action: :list if current_user.try(:student?)
  end

  # Returns the contents of each top level folder as a json object.
  def get_folder_contents
    # Get all child nodes associated with a top level folder that the logged in user is authorized
    # to view. Top level folders include Questionaires, Courses, and Assignments.
    folders = {}
    FolderNode.get.each do |folder_node|
      child_nodes = folder_node.get_children(nil, nil, session[:user].id, nil, nil)
       # Serialize the contents of each node so it can be displayed on the UI
      contents = []
      child_nodes.each do |node|
        contents.push(serialize_folder_to_json(folder_node.get_name, node))
      end
      
      # Store contents according to the root level folder.
      folders[folder_node.get_name] = contents
    end
    
    # Sort assignments by instructor and creation date.
    if folders['Assignments']
      folders['Assignments'] = folders['Assignments'].sort_by do |assignment| 
        [assignment['instructor'], -1 * assignment['creation_date'].to_i] 
      end
    end

    respond_to do |format| 
      format.html { render json: folders } 
    end
  end

  # Returns the contents of the Courses and Questionaire subfolders
  def get_sub_folder_contents
    # Convert the object received in parameters to a FolderNode object.
    #TODO: If the object passed in by params were stored as a FolderNode it
    #      would be easier to process by this method.
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

  def drill
    session[:root] = params[:root]
    redirect_to controller: 'tree_display', action: 'list'
  end

  private
  # Add assignment attributes to json
  def serialize_assignment_to_json(node, json)
    json.merge!(
      "course_id" => node.get_course_id,
      "max_team_size" => node.get_max_team_size,
      "is_intelligent" => node.get_is_intelligent,
      "require_quiz" => node.get_require_quiz,
      "allow_suggestions" => node.get_allow_suggestions,
      "has_topic" => SignUpTopic.where(['assignment_id = ?', node.node_object_id]).first ? true : false
    )
  end

  # Creates a json object that can be displayed by the UI
  def serialize_folder_to_json(folder_type, node)
    json = {
      "nodeinfo" => node,
      "name" => node.get_name,
      "type" => node.type
    }
    
    if folder_type == "Courses" or folder_type == "Assignments"
      json.merge! ({
        "directory" => node.get_directory,
        "creation_date" => node.get_creation_date,
        "updated_date" => node.get_modified_date,
        "institution" => Institution.where(id: node.retrieve_institution_id),
        "private" => assignment_or_course_is_available?(node)
      })
      json["instructor_id"] = node.get_instructor_id
      json["instructor"] = node.get_instructor_id ? User.find(node.get_instructor_id).name(session[:ip]) : nil
      json["is_available"] = assignment_or_course_is_available?(node)
      if folder_type == "Assignments"
        serialize_assignment_to_json(node, json)
      end
    end
    
    return json
  end
  
  # Creates a json object that can be displayed by the UI
  def serialize_sub_folder_to_json(node)
    json = {
      "nodeinfo" => node,
      "name" => node.get_name,
      "type" => node.type,
      "key" => params[:reactParams2][:key],
      "private" => node.get_private,
      "creation_date" => node.get_creation_date,
      "updated_date" => node.get_modified_date
    }
    
    if node.type == "Courses" or node.type == "Assignments"
      json["directory"] = node.get_directory
      json["instructor_id"] = node.get_instructor_id
      json["instructor"] = node.get_instructor_id ? User.find(node.get_instructor_id).name(session[:ip]) : nil
      json["is_available"] = assignment_or_course_is_available?(node)
      if folder_type == "Assignments"
        serialize_assignment_to_json(node, json)
      end
    end
    
    return json
  end

  # Checks if the user is the instructor for the course or assignment node provided.
  # Note: Admin and super admin users are considered instructors for all courses.
  def instructor_for_assignment_or_course?(node)
    is_available(session[:user], node.get_instructor_id)
  end

  # Check if the user is a TA for the course or assignment node provided.
  def ta_for_assignment_or_course?(node)
      ta_mappings = TaMapping.where(ta_id: session[:user].id)
      course_id = node.is_a?(CourseNode) ? node.node_object_id : Assignment.find(node.node_object_id).course_id
      ta_mappings.any? { |ta_mapping| ta_mapping.course_id == course_id }
  end

  # Check if the provided node is avaiable to the logged in user.
  def assignment_or_course_is_available?(node)
    instructor_for_assignment_or_course?(node) or ta_for_assignment_or_course?(node)
  end

end
