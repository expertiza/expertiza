class ReviewChat < ActiveRecord::Base

  # only two types of responses more should be added
  def self.chat_email_response(id,reviewer_id,partial="new_chatemail")
      defn = Hash.new
      defn[:body] = Hash.new
      defn[:body][:partial_name] = partial
      reviewer_email=User.find(reviewer_id).email
    defn[:subject] = "Response posted for submission"
    defn[:body][:type] = " response has been posted for your query .
    Please open the below URL to view.
    http://localhost:3000/review_chats/show/#{id}"
    #AssignmentTeam.find(response_map.reviewee_id).users.each do |user|
    # if assignment.has_topics?
      #  defn[:body][:obj_name] = SignUpTopic.find(SignedUpTeam.topic_id(assignment.id, user.id)).topic_name
      #else
      #  defn[:body][:obj_name] = assignment.name
      #end
     # defn[:body][:first_name] = User.find(user.id).fullname
      defn[:to] = reviewer_email
      Mailer.sync_message(defn).deliver
  end 
end
