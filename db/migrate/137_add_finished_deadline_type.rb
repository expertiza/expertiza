class AddFinishedDeadlineType < ActiveRecord::Migration
  execute "INSERT INTO `deadline_types` VALUES (0,'Finished');"
end
