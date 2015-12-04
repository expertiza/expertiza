module ReviewChatsHelper

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

def self.chat_email_query(id,partial="new_chatemail")
  defn = Hash.new
  defn[:body] = Hash.new
  defn[:body][:partial_name] = partial
  #response_map = ResponseMap.find map_id
  assignment=nil
  @team_id=ReviewChat.find(id).team_id

  teams_users = TeamsUser.where(team_id: @team_id)
  to_mail_list = Array.new
  teams_users.each do |teams_user|
  to_mail_list << User.find(teams_user.user_id).email 
  end
  puts "#{to_mail_list}"
  #reviewer_participant_id =  response_map.reviewer_id
  #participant = Participant.find(reviewer_participant_id)
  #assignment = Assignment.find(participant.parent_id)

  defn[:subject] = "Query posted for submission"
  defn[:body][:type] = " query has been posted for your submission .
  Please open the below URL to view and respond.
  http://localhost:3000/review_chats/show/#{id}"
  #AssignmentTeam.find(response_map.reviewee_id).users.each do |user|
  # if assignment.has_topics?
    #  defn[:body][:obj_name] = SignUpTopic.find(SignedUpTeam.topic_id(assignment.id, user.id)).topic_name
    #else
    #  defn[:body][:obj_name] = assignment.name
    #end
   # defn[:body][:first_name] = User.find(user.id).fullname
    defn[:to] = to_mail_list
    Mailer.sync_message(defn).deliver
  end
end
