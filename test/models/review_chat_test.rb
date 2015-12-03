require 'test_helper'

class ReviewChatTest < ActiveSupport::TestCase

 def setup
	@review_chat = ReviewChat.new(assignment_id: '726', reviewer_id: '29103', team_id: '1000', type_flag: 'Q', content: 'This is test content.')
	end
	
	test "assignment_id should be present" do
	@review_chat.assignment_id = " "
	assert_not @review_chat.assignment_id?
	end

	test "reviewer_id should be present" do
	@review_chat.reviewer_id = " "
	assert_not @review_chat.reviewer_id?
	end

	test "team_id should be present" do
	@review_chat.team_id = " "
	assert_not @review_chat.team_id?
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
