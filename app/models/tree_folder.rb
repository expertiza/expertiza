# == Schema Information
#
# Table name: tree_folders
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  child_type :string(255)
#  parent_id  :integer
#

class TreeFolder < ActiveRecord::Base
end
