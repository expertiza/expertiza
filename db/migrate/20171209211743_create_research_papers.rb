class CreateResearchPapers < ActiveRecord::Migration
  def change
    create_table :research_papers do |t|
      t.string :name
      t.string :topic
      t.date :date
      t.integer :author_id
      t.string :conference

      t.timestamps null: false
    end
  end
end
