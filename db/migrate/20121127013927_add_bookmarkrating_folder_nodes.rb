class AddBookmarkratingFolderNodes < ActiveRecord::Migration[4.2]
  def self.up
    Node.where(['type in ("QuestionnaireTypeNode","QuestionnaireNode")']).find_each(&:destroy)

    parent = TreeFolder.find_by_name('Questionnaires')
    pNode = FolderNode.find_by_node_object_id(parent.id)

    fnode = TreeFolder.create(name: 'Bookmarkrating', child_type: 'QuestionnaireNode')
    pfNode = FolderNode.create(parent_id: pNode.id, node_object_id: fnode.id)

    BookmarkratingQuestionnaire.find_each do |questionnaire|
      QuestionnaireNode.create(parent_id: pfNode.id, node_object_id: questionnaire.id)
    end

    folders = TreeFolder.where(child_type: 'QuestionnaireNode')
    folders.each do |folder|
      folder.update_attribute('parent_id', parent.id)
    end
  end

  def self.down; end
end
