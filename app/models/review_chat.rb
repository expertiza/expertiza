class ReviewChat < ActiveRecord::Base

  # only two types of responses more should be added
  def chat_email
    defn = Hash.new
    defn[:body] = Hash.new
    defn[:body][:partial_name] = partial
    #response_map = ResponseMap.find map_id
    assignment=nil

    #reviewer_participant_id =  response_map.reviewer_id
   # participant = Participant.find(reviewer_participant_id)
    #assignment = Assignment.find(participant.parent_id)

    defn[:subject] = "A new submission is available for "
      defn[:body][:type] = "Author Feedback"
     # AssignmentTeam.find(response_map.reviewee_id).users.each do |user|
       # if assignment.has_topics?
        #  defn[:body][:obj_name] = SignUpTopic.find(SignedUpTeam.topic_id(assignment.id, user.id)).topic_name
        #else
        #  defn[:body][:obj_name] = assignment.name
        #end
       # defn[:body][:first_name] = User.find(user.id).fullname
        defn[:to] = "ahuja.rohit910@gmail.com"
        Mailer.sync_message(defn).deliver
    end
    

end
