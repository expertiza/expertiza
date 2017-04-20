class AddFinishedDeadlineType < ActiveRecord::Migration
  execute "INSERT INTO `deadline_types` VALUES (12,'Finished');"
end
