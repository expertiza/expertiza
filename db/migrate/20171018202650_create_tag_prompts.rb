class CreateTagPrompts < ActiveRecord::Migration
  def change
    create_table :tag_prompts do |t|
      t.string :prompt
      t.string :desc
      t.string :control_type

      t.timestamps null: false
    end
  end
end
