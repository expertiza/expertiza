class TreeFolder < ActiveRecord::Base
  belongs_to :node, class_name: 'Node', foreign_key: 'parent_id'
end
