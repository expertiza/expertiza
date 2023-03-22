class QuestionnaireTypeNode < FolderNode
  belongs_to :table, class_name: 'TreeFolder', foreign_key: 'node_object_id', inverse_of: false
  belongs_to :node_object, class_name: 'TreeFolder', inverse_of: false

  def self.table
    'tree_folders'
  end

  # this function returns the list of nodes corresponding to each folder
  # from the list of folders passed as parameter
  def self.return_nodes_list(folders)
    nodes = []
    folders.each do |folder|
      node = FolderNode.find_by(node_object_id: folder.id)
      nodes << node if node
    end
    nodes
  end

  # This function returns the child nodes of all the folders given its parent node name.
  def self.get(_sortvar = nil, _sortorder = nil, _user_id = nil, _show = nil, _parent_id = nil, _search = nil)
    parent = TreeFolder.find_by(name: 'Questionnaires')
    folders = TreeFolder.where(parent_id: parent.id)
    return_nodes_list(folders)
  end

  def get_partial_name
    'questionnaire_type_actions'
  end

  # returns the name of the folder from the node object id
  def get_name
    TreeFolder.find(node_object_id).name
  end

  # returns the children from the get function of QuestionnaireNode model
  def get_children(sortvar = nil, sortorder = nil, user_id = nil, show = nil, _parent_id = nil, search = nil)
    QuestionnaireNode.get(sortvar, sortorder, user_id, show, node_object_id, search)
  end
end
