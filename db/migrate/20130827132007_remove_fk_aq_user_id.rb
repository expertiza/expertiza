class RemoveFkAqUserId < ActiveRecord::Migration[4.2]
  def self.up
    execute 'alter table assignment_questionnaires drop foreign key fk_aq_user_id;'
  rescue StandardError
  end

  def self.down
    execute "ALTER TABLE `assignment_questionnaires`
             ADD CONSTRAINT `fk_aq_user_id`
             FOREIGN KEY (user_id) references users(id)"
  rescue StandardError
  end
end
