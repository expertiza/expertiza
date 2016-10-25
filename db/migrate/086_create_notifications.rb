class CreateNotifications < ActiveRecord::Migration
  def self.up
        
    create_table :notification_limits do |t|
      t.column :user_id, :integer, :null => false
      t.column :assignment_id, :integer, :null => true
      t.column :questionnaire_id, :integer, :null => true
      t.column :limit, :integer, :null => false, :default => 15          
    end
    
    
    
    User.find_by_sql("select * from users where role_id in (select id from roles where not (parent_id is null))").each{
      |user|
      execute "INSERT INTO `notification_limits` (`user_id`, `limit`) VALUES
            (#{user.id}, 15);"       
    }
  end

  def self.down
    drop_table :notification_limits
  end
end
