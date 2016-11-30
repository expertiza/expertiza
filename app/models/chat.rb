class Chat < ActiveRecord::Base
  belongs_to :response_map
  has_many :messages , :dependent => :delete_all
  validates :review_response_map_id, uniqueness: true
end
