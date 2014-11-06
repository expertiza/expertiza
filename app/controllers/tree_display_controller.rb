class TreeDisplayController < ApplicationController
  helper :application

  # Database group names - used to translate from session variable string syntax to database label syntax
  @@Groups = {
      'Questionnaires'          => 'Questionnaires',
      'Review rubrics'          => 'Review',
      'Metareview rubrics'      => 'Metareview',
      'Teammate review rubrics' => 'Teammate Review',
      'Author feedbacks'        => 'Author Feedback',
      'Global survey'           => 'Global Survey',
      'Surveys'                 => 'Survey',
      'Course evaluations'      => 'Course Evaluation',
      'Courses'                 => 'Courses',
      'Bookmarkrating'          => 'Bookmarkrating',
      'Assignments'             => 'Assignments'
  }

  def action_allowed?
    true
  end

  # called when the display is requested
  def index
    session[:root] = params[:root]
    group = getGroup session[:menu]

    node_object = TreeFolder.find_by_name(group)
    if not group.blank? and not node_object.blank?
      session[:root] = FolderNode.find_by_node_object_id(node_object.id).id
    end

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

    search = search_string

    display = params[:display]
    if display
      sortvar = display[:sortvar]
      sortorder = display[:sortorder]
    end

    sortvar ||= 'created_at'
    sortorder ||= 'desc'

    if session[:root]
      root_node = Node.find(session[:root])
      child_nodes = root_node.get_children(sortvar,sortorder,session[:user].id,@show,nil,search)
    else
      child_nodes = FolderNode.get()
    end
    locals  search:       search,
            sortvar:      sortvar,
            sortorder:    sortorder,
            root_node:    root_node,
            child_nodes:  child_nodes,
            filternode:   params[:filternode],
            searchnode:   params[:searchnode]
  end

private

  # render local variable hash for view
  # reference: http://thepugautomatic.com/2013/05/locals/
  def locals(values)
    render locals: values
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

  def getGroup menu
    if menu and menu.selected
      # first menu item is most specific/nested menu selected item in dropdown menus
      menu_item_label= MenuItem.where(name: menu.selected).first.label
    end
    @@Groups[menu_item_label]
  end
end