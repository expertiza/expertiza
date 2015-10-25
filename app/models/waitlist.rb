class Waitlist < ActiveRecord::Base

  def self.cancel_all_waitlists(team_id, assignment_id)
    waitlisted_topics = SignUpTopic.find_waitlisted_topics(assignment_id,team_id)
    if !waitlisted_topics.nil?
      for waitlisted_topic in waitlisted_topics
        entry = SignedUpTeam.find(waitlisted_topic.id)
        entry.destroy
      end
    end

  end


  def waitlist_teams (param_id, user_id, team_id, topic_id, assignment_id)
    #check whether user has signed up already
    user_signup = other_confirmed_topic_for_user(assignment_id, team_id)

    sign_up = SignedUpTeam.new
    sign_up.topic_id = param_id
    sign_up.team_id = team_id
    result = false
    if user_signup.size == 0

      # Using a DB transaction to ensure atomic inserts
      ActiveRecord::Base.transaction do
        #check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        if slotAvailable?(topic_id)
          #if slot exist, then confirm the topic for the team and delete all the waitlist for this team
          cancel_all_waitlists(team_id, assignment_id)
          sign_up.is_waitlisted = false
          sign_up.save
        else
          sign_up.is_waitlisted = true
        end
        if sign_up.save
          result = true
        end
      end
      else
        #If all the topics choosen by the user are waitlisted,
        for user_signup_topic in user_signup
          if user_signup_topic.is_waitlisted == false
            SignUpSheetController.flash_signedup_topic()

            return false
          end
        end

        # Using a DB transaction to ensure atomic inserts
        ActiveRecord::Base.transaction do
          #check whether user is clicking on a topic which is not going to place him in the waitlist
          if !slotAvailable?(topic_id)
            sign_up.is_waitlisted = true
            if sign_up.save
              result = true
            end
          else
            #if slot exist, then confirm the topic for the team and delete all the waitlist for this team
            cancel_all_waitlists(team_id, assignment_id)
            sign_up.is_waitlisted = false
            sign_up.save
            result = true
          end
        end
        end

    result
  end
end
