class CreateSignUpTopics < ActiveRecord::Migration
  def self.up
    create_table :sign_up_topics do |t|
      t.column :topic_name, :text, :null => false
      t.column :assignment_id, :integer, :null => false
      t.column :max_choosers, :integer, :null => false
      t.column :category, :text
      t.column :topic_identifier, :string, :limit => 10
      t.column :start_date, :datetime
      t.column :due_date, :datetime
    end

    add_index "sign_up_topics", ["assignment_id"], :name => "fk_sign_up_categories_sign_up_topics"

    execute "alter table sign_up_topics
             add constraint fk_sign_up_topics_assignments
             foreign key (assignment_id) references assignments(id)"  
	
  end

  def self.down
    drop_table :sign_up_topics
  end
end

