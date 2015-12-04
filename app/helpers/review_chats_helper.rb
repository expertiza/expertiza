module ReviewChatsHelper

def self.chat_email_response(id,reviewer_id,partial="new_chatemail")
    defn = Hash.new
    defn[:body] = Hash.new
    defn[:body][:partial_name] = partial
    reviewer_email=User.find(reviewer_id).email
    defn[:subject] = "Response posted for submission"
    defn[:body][:type] = " response has been posted for your query .
    Please open the below URL to view.
    http://expertiza.ncsu.edu/review_chats/show/#{id}"
    defn[:to] = reviewer_email
    Mailer.sync_message(defn).deliver
  end 

def self.chat_email_query(id,partial="new_chatemail")
  defn = Hash.new
  defn[:body] = Hash.new
  defn[:body][:partial_name] = partial
  assignment=nil
  @team_id=ReviewChat.find(id).team_id
  teams_users = TeamsUser.where(team_id: @team_id)
  to_mail_list = Array.new
  teams_users.each do |teams_user|
  to_mail_list << User.find(teams_user.user_id).email 
  end
  defn[:subject] = "Query posted for submission"
  defn[:body][:type] = " query has been posted for your submission .
  Please open the below URL to view and respond.
  http://expertiza.ncsu.edu/review_chats/show/#{id}"
  defn[:to] = to_mail_list
  Mailer.sync_message(defn).deliver
  end
end
