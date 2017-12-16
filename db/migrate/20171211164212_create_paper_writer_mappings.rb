class CreatePaperWriterMappings < ActiveRecord::Migration
  def change
    create_table :paper_writer_mappings do |t|
      t.integer :writer_id
      t.integer :paper_id

      t.timestamps null: false
    end
  end
end
