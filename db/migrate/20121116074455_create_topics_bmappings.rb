class CreateTopicsBmappings< ActiveRecord::Migration[4.2]
  def self.up
    if table_exists?(:bmappings_sign_up_topics) == false
      create_table :bmappings_sign_up_topics, id: false do |t|
        t.column 'sign_up_topic_id', :integer, null: false
        t.column 'bmapping_id', :integer, null: false
      end
    end
  end

  def self.down
    drop_table :bmappings_sign_up_topics
  end
end
