<<<<<<< HEAD
class AddTopicIdToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :topic_id, :integer, :null => true  
  end

  def self.down
  end
end
=======
class AddTopicIdToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :topic_id, :integer, :null => true  
  end

  def self.down
  end
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
