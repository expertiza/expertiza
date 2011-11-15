<<<<<<< HEAD
class UpdateFieldsInSignUpTopics < ActiveRecord::Migration
  def self.up
    begin
      remove_column :sign_up_topics, :start_date
      remove_column :sign_up_topics, :due_date
    rescue
    end    
  end

  def self.down
  end
=======
class UpdateFieldsInSignUpTopics < ActiveRecord::Migration
  def self.up
    begin
      remove_column :sign_up_topics, :start_date
      remove_column :sign_up_topics, :due_date
    rescue
    end    
  end

  def self.down
  end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end