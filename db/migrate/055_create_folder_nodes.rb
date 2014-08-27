class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    folders = TreeFolder.all
    folders.each {
      |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil)
    }
  end

  def self.down
    nodes = FolderNode.all
    nodes.each { |node| node.destroy }    
  end
end
