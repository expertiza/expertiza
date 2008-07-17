class CreateTreeFolders < ActiveRecord::Migration
  def self.up
    create_table :tree_folders do |t|
      t.column :name, :string
      t.column :child_type, :string
    end      
    
    TreeFolder.create(:name => 'Questionnaires', :child_type => 'QuestionnaireTypeNode')
    TreeFolder.create(:name => 'Courses', :child_type => 'CourseNode')
    TreeFolder.create(:name => 'Assignments', :child_type => 'AssignmentNode')
  end

  def self.down
    drop_table :tree_folders
  end
end
