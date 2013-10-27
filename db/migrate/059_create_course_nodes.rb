class CreateCourseNodes < ActiveRecord::Migration
  def self.up
     courses = Course.find(:all)
     
     folder = TreeFolder.find_by_name('Courses')
     parent = FolderNode.find_by_node_object_id(folder.id)
     
     courses.each{
       |course|
       CourseNode.create(:node_object_id => course.id, :parent_id => parent.id)         
     }
  end

  def self.down
    nodes = CourseNode.find(:all)
    nodes.each {|node| node.destroy }
  end
end
