class FolderNode < Node
  belongs_to :folder, class_name: 'TreeFolder', foreign_key: 'node_object_id'
  belongs_to :node_object, class_name: 'TreeFolder'

  def self.get(_sortvar = nil, _sortorder = nil, _user_id = nil, _show = nil, _parent_id = nil, _search = nil)
    joins(:folder).where('type = ? and tree_folders.parent_id is NULL', self)
  end

  def get_name
    TreeFolder.find(node_object_id).name
  end

  def get_partial_name
    if parent_id.nil?
      get_name.downcase + '_folder_actions'
    else
      'questionnaire_types_actions'
    end
  end

  def get_child_type
    TreeFolder.find(node_object_id).child_type
  end

  def get_children(sortvar = nil, sortorder = nil, user_id = nil, show = nil, parent_id = nil, search = nil)
    parent_id = folder.id unless folder.parent_id.nil?
    Object.const_get(get_child_type).get(sortvar, sortorder, user_id, show, parent_id, search)
  end
end
