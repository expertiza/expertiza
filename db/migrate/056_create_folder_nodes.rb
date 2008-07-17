class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    folders = TreeFolder.find(:all)
    folders.each {
      |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil, :table => folder.name.downcase)       
    }
  end

  def self.down
    nodes = FolderNode.find(:all)
    nodes.each { |node| node.destroy }    
  end
end
