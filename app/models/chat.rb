class Chat < ActiveRecord::Base
  belongs_to :response_map
  has_many :messages
end
