class CreateAutomatedMetareviews < ActiveRecord::Migration
  def self.up
    create_table :automated_metareviews do |t|
      t.float :relevance
      t.float :content_summative
      t.float :content_problem
      t.float :content_advisory
      t.float :tone_positive
      t.float :tone_negative
      t.float :tone_neutral
      t.integer :quantity
      t.integer :plagiarism
      t.integer :version_num
      t.integer :response_id
      
      t.timestamps
    end
    
    #add a foreign key
    execute <<-SQL
      ALTER TABLE automated_metareviews
        ADD CONSTRAINT fk_automated_metareviews_responses_id
        FOREIGN KEY (response_id)
        REFERENCES responses(id)
    SQL
    
  end
             
  def self.down
    drop_table :automated_metareviews
  end
end
