class Version < ActiveRecord::Base
  attr_accessible :item_id,:item_type,:event,:whodunnit,:object,:created_at
end
