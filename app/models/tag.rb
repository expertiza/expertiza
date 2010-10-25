class Tag < ActiveRecord::Base
	has_many :qualifiers
	has_many :topicmappings
end
