class CreateSignedUpUsers < ActiveRecord::Migration
  def self.up
    create_table :signed_up_users do |t|
      t.column :topic_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :is_waitlisted, :boolean, :null => false
      t.column :preference_priority_number, :integer      
    end

    add_index "signed_up_users", ["topic_id"], :name => "fk_signed_up_users_sign_up_topics"

    execute "alter table signed_up_users
             add constraint fk_signed_up_users_sign_up_topics
             foreign key (topic_id) references sign_up_topics(id)"        
  end

  def self.down
    drop_table :signed_up_users
  end
end
