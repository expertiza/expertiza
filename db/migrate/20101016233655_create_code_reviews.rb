class CreateCodeReviews < ActiveRecord::Migration
  def self.up
    create_table :code_reviews do |t|
      t.text :title
      t.text :changes
      t.integer :files_uploaded, :default=>0
      t.timestamps
    end
    
    add_column :participants, :code_review_id, :integer
    execute "INSERT INTO site_controllers(name, permission_id, builtin) values('code_review', 8, 0);"

  end

  def self.down
    drop_table :code_reviews
  end
end
