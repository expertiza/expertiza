<<<<<<< HEAD
<<<<<<< HEAD
class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    folders = TreeFolder.find(:all)
    folders.each {
      |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil)       
    }
  end

  def self.down
    nodes = FolderNode.find(:all)
    nodes.each { |node| node.destroy }    
  end
end
=======
class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    folders = TreeFolder.find(:all)
    folders.each {
      |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil)       
    }
  end

  def self.down
    nodes = FolderNode.find(:all)
    nodes.each { |node| node.destroy }    
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    folders = TreeFolder.find(:all)
    folders.each {
      |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil)       
    }
  end

  def self.down
    nodes = FolderNode.find(:all)
    nodes.each { |node| node.destroy }    
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
