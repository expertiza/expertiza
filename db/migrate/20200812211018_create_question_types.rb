class CreateQuestionTypes < ActiveRecord::Migration
  def change
    create_table :question_types do |t|
      t.string :type
    end
    execute "INSERT INTO `question_types` VALUES (1,'Criterion'),(2,'Scale'),(3,'Dropdown'),(4,'Checkbox'),(5,'TextArea'),(6,'TextField'),(7,'UploadFile'),(8,'SectionHeader'),(9,'TableHeader'),(10,'ColumnHeader');"
  end
end
