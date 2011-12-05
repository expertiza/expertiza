class CreateTopicsBmappings< ActiveRecord::Migration
  def self.up
    create_table :bmappings_sign_up_topics, :id=>false do |t|
    	t.column "sign_up_topic_id", :integer, :null=> false
    	t.column "bmapping_id", :integer, :null => false    	
    end
  end

  def self.down
    drop_table :bmappings_sign_up_topics
  end
end
