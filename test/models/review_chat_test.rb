require 'test_helper'

class ReviewChatTest < ActiveSupport::TestCase

 def setup
	@review_chat = ReviewChat.new(response_map_id: '90207', type_flag: 'Q', content: 'This is test content.')
	end
	
	test "response_map_id should be present" do
	@review_chat.response_map_id = " "
	assert_not @review_chat.response_map_id?
	end

	test "content should have a maximum length of 255" do
	@review_chat.content = "a" * 250
	assert @review_chat.valid?
	end

	test "content should be present (nonblank)" do
	@review_chat.content = " " * 6
	assert_not @review_chat.valid?
	end

end
