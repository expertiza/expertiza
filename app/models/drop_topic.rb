class DropTopic  < DeadlineType

   def email_list(assignment_id)
         emails = mail_sign_up_topic_users(assignment_id)
         emails
   end

   def mail_sign_up_topic_users(assignment_id)
       sign_up_topics = SignUpTopic.where(['assignment_id = ?', assignment_id])
       assignment = Assignment.find(self.assignment_id)
       emails =[]
       for topic in sign_up_topics
         signed_up_teams = SignedUpTeam.where(['topic_id = ?', topic.id])
         unless assignment.team_assignment?
           for signed_user in signed_up_teams
             uid  = signed_user.team_id
             user = User.find(uid)
             emails << user.email
           end
         else
           for signedUser in signed_up_teams
             teamid = signed_user.team_id
             team_members = TeamsUser.where(team_id: teamid)
             for team_member in team_members
               user = User.find(team_member.user_id)
               emails << user.email
             end
           end
         end
       end
       emails
    end

end
