class CreateAssignmentNodes < ActiveRecord::Migration
  def self.up
     assignments = Assignment.find(:all)
     
     folder = TreeFolder.find_by_name('Assignments')
     parent = FolderNode.find_by_node_object_id(folder.id)
     
     assignments.each{
       |assignment|
       AssignmentNode.create(:node_object_id => assignment.id, :parent_id => parent.id)         
     }        
  end

  def self.down
    nodes = AssignmentNode.find(:all)
    nodes.each { |node| node.destroy }
  end
end
