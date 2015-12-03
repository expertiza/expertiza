class ReviewChat < ActiveRecord::Base

  validates_length_of :content , :maximum => 255,message: "Length must be less that 255 characters"
  validates_presence_of :content, message: "Content cannot be blank"

end
