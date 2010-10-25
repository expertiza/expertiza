class Bmapping < ActiveRecord::Base
	belongs_to :user
	belongs_to :bookmark
	has_many :qualifiers
end
