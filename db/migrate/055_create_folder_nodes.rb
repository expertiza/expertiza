class CreateFolderNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :name, :string
    add_column :nodes, :lft, :integer
    add_column :nodes, :rgt, :integer
    add_column :nodes, :depth, :integer

    TreeFolder.find_each do |folder|
      FolderNode.create(:node_object_id => folder.id, :parent_id => nil)
    end
  end

  def self.down
    remove_column :nodes, :name
    remove_column :nodes, :lft
    remove_column :nodes, :rgt
    remove_column :nodes, :depth

    nodes = FolderNode.all
    nodes.each { |node| node.destroy }    
  end
end
