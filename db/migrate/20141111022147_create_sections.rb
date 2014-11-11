class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name, :null => false
      t.text :desc_text

      t.timestamps
    end
  end

  def self.up
    add_index :sections,:id
  end
end
