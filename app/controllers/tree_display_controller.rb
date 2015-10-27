class TreeDisplayController < ApplicationController
  helper :application

  def action_allowed?
    true
  end

  # direct access to course evaluations
  def goto_course_evaluations
    node_object = TreeFolder.find_by_name('Course Evaluation')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def goto_bookmarkrating_rubrics
    node_object = TreeFolder.find_by_name('Bookmarkrating')
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    redirect_to :controller => 'tree_display', :action => 'list'
  end

 # direct access
 def go_to_menu_items
    name = params[:params1]
    if name == "Review rubrics"
      name = "Review"
    elsif name == "Teammate review rubrics"
      name = "Teammate Review"
    elsif name == "Metareview rubrics"
      name = "Metareview"
    elsif name == "Author feedbacks"
      name = "Author Feedback"
    elsif name == "Global surveys"
      name = "Global Survey"
    elsif name == "Course evaluations"
      name = "Course Evaluation"
    end

    node_object = TreeFolder.find_by_name(name)
    puts node_object.inspect
    puts node_object.id
    session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    session_id = session[:root]
    puts session[:root].inspect
    redirect_to :controller => 'tree_display', :action => 'list'
 end

  # called when the display is requested
  # ajbudlon, July 3rd 2008
  def list
    redirect_to controller: :student_task, action: :list if current_user.student?
  end

  def get_folder_node_ng
    respond_to do |format|
      format.html {render json: FolderNode.get()}
    end
  end

  def get_children_node_ng
    childNodes = {}
    if params[:reactParams][:child_nodes].is_a? String
      childNodes = JSON.parse(params[:reactParams][:child_nodes])
    else
      childNodes = params[:reactParams][:child_nodes]
    end
    tmpRes = {}
    res = {}
    for node in childNodes
      # Declaring Foldernode Object as New
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
      call_function ="get_folder_node_ng"
      populate_rows(tmpRes,call_function)
  end

  def display_row(node)
    tmpObject = {}
    tmpObject["nodeinfo"] = node
    # all the child nodes names got and put in tmpObject from respective controller actions
    tmpObject["name"] = node.get_name
    tmpObject["type"] = node.type
    if node.type == 'CourseNode' || node.type == "AssignmentNode"
      tmpObject["directory"] = node.get_directory
      tmpObject["creation_date"] = node.get_creation_date
      tmpObject["updated_date"] = node.get_modified_date
      tmpObject["private"] = node.get_private
      instructor_id = node.get_instructor_id
      tmpObject["instructor_id"] = instructor_id
      unless (instructor_id.nil?)
        tmpObject["instructor"] = User.find(instructor_id).name
      else
        tmpObject["instructor"] = nil
      end

      tmpObject["is_available"] = is_available(session[:user], instructor_id) || (session[:user].role_id == 6 && Ta.get_my_instructors(session[:user].id).include?(instructor_id) && ta_for_current_course?(node))
      if node.type == "AssignmentNode"
        tmpObject["course_id"] = node.get_course_id
        tmpObject["max_team_size"] = node.get_max_team_size
        tmpObject["is_intelligent"] = node.get_is_intelligent
        tmpObject["require_quiz"] = node.get_require_quiz
        tmpObject["allow_suggestions"] = node.get_allow_suggestions
        tmpObject["has_topic"] = SignUpTopic.where(['assignment_id = ?', node.node_object_id]).first ? true : false
      end
    end
    tmpObject
  end

  def populate_rows(list,call_function)
    if call_function == "get_folder_node_ng"
      tmpRes ={}
      tmpRes = list
      res = {}
       for nodeType in tmpRes.keys
        # declaring a new array
        res[nodeType] =  Array.new
        for node in tmpRes[nodeType]
          res[nodeType] << display_row(node)
        end
       end

    else
      tmpRes = list
      res = []
      if tmpRes
        for child in tmpRes
          res2 = {}
          res2 = display_row child
          res2["key"] = params[:reactParams2][:key]
          res << res2
        end
      end
    end
    page_render(res)
  end

  def page_render(list)
    respond_to do |format|
      format.html {render json: list}
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
    return false
  end

  def get_children_node_2_ng
    childNodes = {}
    if params[:reactParams2][:child_nodes].is_a? String
      childNodes = JSON.parse(params[:reactParams2][:child_nodes])
    else
      childNodes = params[:reactParams2][:child_nodes]
    end

    res = []
    fnode = eval(params[:reactParams2][:nodeType]).new
    childNodes.each do |key, value|
      fnode[key] = value
    end

    ch_nodes = fnode.get_children(nil, nil, session[:user].id, nil, nil)

    call_function = "get_children_node_2_ng"

    populate_rows(ch_nodes, call_function)



  end

  def bridge_to_is_available
    user = session[:user]
    owner_id = params[:owner_id]
    is_available(user, owner_id)
  end

  def get_session_last_open_tab
    res = session[:last_open_tab]
    respond_to do |format|
      format.html {render json: res}
    end
  end

  def set_session_last_open_tab
    session[:last_open_tab] = params[:tab]
    res = session[:last_open_tab]
    respond_to do |format|
      format.html {render json: res}
    end
  end

  def drill
    session[:root] = params[:root]
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def filter
    #Search String - Assignment Name or Course Name
    search = params[:filter_string]
    puts search.inspect
    #Filter Node : QAN - Questionnaire by Assignment Name
    #              ACN - Assignment By Course Name
    filter_node = params[:filternode]
    qid = 'filter+'

    if filter_node == 'QAN'
      #Find assignment by name
      assignment = Assignment.find_by_name(search)
      if assignment
        #find questionnaires for assignment
        assignment_questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment.id)
        if assignment_questionnaires
          #Add Questionnaire IDs to qid
          assignment_questionnaires.each { |q|  qid << "#{q.questionnaire_id.to_s}+" }
          #Set session[:root] to Questionnaire
          session[:root] = 1
        end
      end
    elsif filter_node == 'ACN'
      #Set session[:root] to Course
      session[:root] = 2
      # Add Course name to qid
      qid <<  search
    end
    return qid
  end

  end
