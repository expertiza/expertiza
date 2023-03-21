class QuestionnaireTypeNode < FolderNode
  belongs_to :table, class_name: 'TreeFolder', foreign_key: 'node_object_id', inverse_of: false
  belongs_to :node_object, class_name: 'TreeFolder', inverse_of: false

  def self.table
    'tree_folders'
  end

  def self.get(_sortvar = nil, _sortorder = nil, _user_id = nil, _show = nil, _parent_id = nil, _search = nil)
    parent = TreeFolder.find_by(name: 'Questionnaires')
    folders = TreeFolder.where(parent_id: parent.id)
    nodes = []
    folders.each do |folder|
      node = FolderNode.find_by(node_object_id: folder.id)
      nodes << node if node
    end
    nodes
  end

  def get_partial_name
    'questionnaire_type_actions'
  end

  def get_name
    TreeFolder.find(node_object_id).name
  end

  def get_children(sortvar = nil, sortorder = nil, user_id = nil, show = nil, _parent_id = nil, search = nil)
    QuestionnaireNode.get(sortvar, sortorder, user_id, show, node_object_id, search)
  end
end
