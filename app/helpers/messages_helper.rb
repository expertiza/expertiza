module MessagesHelper
def self_or_other(message)
    message.user == current_user ? "self" : "other"
  end
def reviewee_or_reviewer(message)
	response = ReviewResponseMap.find(message.chat.review_response_map_id)
	message.user ==response.reviewer.user ? "Reviewer" : "Reviewee"
end
end