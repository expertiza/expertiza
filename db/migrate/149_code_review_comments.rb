class CreateCodeReviewComments < ActiveRecord::Migration
  def self.up
    create_table :code_review_comments do |t|
      t.integer  :participantid
      t.integer  :codefileid
      t.string   :title
      t.text     :body
      t.integer  :r_begins
      t.integer  :r_end
      t.integer  :r_scroll
      t.timestamps
    end 
  end

  def self.down
    drop_table :code_review_comments
  end
end
