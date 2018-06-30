class CreateFileInstructions < ActiveRecord::Migration
  def change
    create_table :file_instructions do |t|
      t.string :host_url
      t.string :file_type
      t.string :instructions

      t.timestamps null: false
    end
  end
end
