class ReviewChat < ActiveRecord::Base

  belongs_to :map, :class_name => 'ReviewResponseMap', :foreign_key => 'map_id'

  validates_length_of :content , :maximum => 255,message: "Length must be less that 255 characters"
  validates_presence_of :content, message: "Content cannot be blank"

  def self.get_response_map(review_chat)
  	response_map = ReviewResponseMap.find(review_chat.response_map_id)
  end

  def self.get_chat_log(map_id)
  	ReviewChat.where(:response_map_id => map_id)
  end
end

