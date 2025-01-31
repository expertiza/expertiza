class CreateSuggestionComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :suggestion_comments do |t|
      t.column :comments, :text
      t.column :commenter,     :string
      t.column :vote,          :string
      t.column :suggestion_id, :int
      t.column :created_at,    :datetime
    end
  end

  def self.down
    drop_table :suggestion_comments
  end
end
