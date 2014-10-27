# == Schema Information
#
# Table name: institutions
#
#  id   :integer          not null, primary key
#  name :string(255)      default(""), not null
#

class Institution < ActiveRecord::Base
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name
end
