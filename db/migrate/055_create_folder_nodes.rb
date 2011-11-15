<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
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
<<<<<<< HEAD
=======
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
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
