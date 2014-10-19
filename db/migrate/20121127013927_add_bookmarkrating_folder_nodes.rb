class AddBookmarkratingFolderNodes < ActiveRecord::Migration
  def self.up

    #Node.find(:all, :conditions => ['type in ("QuestionnaireTypeNode","QuestionnaireNode")']).each{
    Node.where('type in ("QuestionnaireTypeNode","QuestionnaireNode")').each{
        | node |
      node.destroy
    }

    parent = TreeFolder.find_by_name("Questionnaires")
    pNode = FolderNode.find_by_node_object_id(parent.id)

    fnode = TreeFolder.create(:name => 'Bookmarkrating', :child_type => 'QuestionnaireNode')
    pfNode = FolderNode.create(:parent_id => pNode.id, :node_object_id => fnode.id)

    BookmarkratingQuestionnaire.find_each{
        | questionnaire |
      QuestionnaireNode.create(:parent_id => pfNode.id, :node_object_id => questionnaire.id)
    }



    #folders = TreeFolder.find_all_by_child_type('QuestionnaireNode')
    folders = TreeFolder.where(child_type: 'QuestionnaireNode')
    folders.each {
        | folder |
      folder.update_attribute("parent_id",parent.id)
    }
  end

  def self.down
  end

end
