class DelayedMailer
  #Keeps info required for delayed job
  #to send mail at a particular time
  attr_accessor :assignment_id
  attr_accessor :deadline_type
  attr_accessor :due_at

  @@count = 0

  def initialize(assignment_id, deadline_type, due_at)
    self.assignment_id=assignment_id
    self.deadline_type=deadline_type
    self.due_at = due_at
  end

  def perform
    assignment = Assignment.find(self.assignment_id)
    if assignment != nil && assignment.id != nil
      if(self.deadline_type == "metareview")
        mail_metareviewers
        if (assignment.team_assignment?)
          teamMails = getTeamMembersMail
          email_reminder(teamMails, "teammate review")
        end
      end

      if(self.deadline_type == "review")
        mail_reviewers # to all reviewers
      end

      if(self.deadline_type == "submission"|| self.deadline_type == "resubmission")
        mail_signed_up_users  # to all signed up users
      end

      if(self.deadline_type == "drop_topic")
        sign_up_topics = SignUpTopic.where( ['assignment_id = ?', self.assignment_id])
        if(sign_up_topics != nil && sign_up_topics.count != 0)
          mail_signed_up_users #reminder to signed_up users of the assignment
        end
      end

      if(self.deadline_type == "signup")
        sign_up_topics = SignUpTopic.where( ['assignment_id = ?', self.assignment_id])
        if(sign_up_topics != nil && sign_up_topics.count != 0)
          mail_assignment_participants #reminder to all participants
        end
      end

      if(self.deadline_type == "team_formation")
        assignment = Assignment.find(self.assignment_id)
        if(assignment.team_assignment?)
          mail_assignment_participants
        else
          emails = Array.new
          email_reminder(emails, self.deadline_type)
        end
      end
    end
  end

  # Find the signed_up_users of the assignment and send mails to them
  def mail_signed_up_users
    emails = Array.new
    assignment = Assignment.find(self.assignment_id)
    sign_up_topics = SignUpTopic.where( ['assignment_id = ?', self.assignment_id])

    # If there are sign_up topics for an assignement then send a mail toonly signed_up_users else send a mail to all participants
    if(sign_up_topics == nil || sign_up_topics.count == 0)
      unless assignment.team_assignment?
        mail_assignment_participants
      else
        teamMails = getTeamMembersMail
        for mail in teamMails
          emails << mail
          email_reminder(emails, self.deadline_type)
        end
      end
    else
      for topic in sign_up_topics
        signedUpUsers = SignedUpUser.where( ['topic_id = ?', topic.id])
        unless assignment.team_assignment?
          for signedUser in signedUpUsers
            uid  = signedUser.creator_id
            user = User.find(uid)
            emails << user.email
          end
        else
          for signedUser in signedUpUsers
            teamid  = signedUser.creator_id
            team_members = TeamsUser.where(team_id: teamid)
            for team_member in team_members
              user = User.find(team_member.user_id)
              emails << user.email
            end
          end
        end
      end
      email_reminder(emails, self.deadline_type)
    end
    end

  def getTeamMembersMail
    teamMembersMailList = Array.new
    assignment = Assignment.find(self.assignment_id)
    teams = Team.where( ['parent_id = ?', self.assignment_id])
    for team in teams
      team_participants = TeamsUser.where( ['team_id = ?', team.id])
      for team_participant in team_participants
        user = User.find(team_participant.user_id)
        teamMembersMailList << user.email
      end
    end
    return teamMembersMailList
  end

  def mail_metareviewers
    emails = Array.new
    #find reviewers for the assignment
    reviewer_tuples = ResponseMap.where( ['reviewed_object_id = ? AND (type = "ParticipantReviewResponseMap" OR type = "TeamReviewResponseMap")', self.assignment_id])
    for reviewer in reviewer_tuples
      #find metareviewers - people who will review the reviewers
      meta_reviewer_tuples = ResponseMap.where( ['reviewed_object_id = ? AND type = "MetareviewResponseMap"', reviewer.id])
      for metareviewer in meta_reviewer_tuples
        participant = Participant.where( ['parent_id = ? AND id = ?', self.assignment_id, metareviewer.reviewer_id])
        uid  = participant.user_id
        user = User.find(uid)
        emails << user.email
      end
    end
    email_reminder(emails, self.deadline_type)
  end

  def mail_reviewers
    emails = Array.new
    reviewer_tuples = ResponseMap.where( ['reviewed_object_id = ? AND (type = "ParticipantReviewResponseMap" OR type = "TeamReviewResponseMap")', self.assignment_id])
    for reviewer in reviewer_tuples
      participant = Participant.where( ['parent_id = ? AND id = ?', self.assignment_id, reviewer.reviewer_id])
      uid  = participant.user_id
      user = User.find(uid)
      emails << user.email
    end
    email_reminder(emails, self.deadline_type)
  end

  def mail_assignment_participants
    emails = Array.new
    assignment = Assignment.find(self.assignment_id)
    for participant in assignment.participants
      uid=participant.user_id
      user=User.find(uid)
      emails << user.email
    end
    email_reminder(emails, self.deadline_type)
  end

  def email_reminder(emails, deadlineType)
    assignment = Assignment.find(self.assignment_id)
    subject = "Message regarding #{deadlineType} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadlineType} for assignment #{assignment.name}. Deadline is #{self.due_at}.If you have already done the  #{deadlineType}, Please ignore this mail."

    if (deadlineType == "resubmission")
      body += "Author feedback is optional. However, if you want to give author feedback then the deadline is #{self.due_at}."
      end

      #emails<<"vikas.023@gmail.com"
      #emails<<"vsharma4@ncsu.edu"
      @@count = @@count+1
      Rails.logger.info "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      Rails.logger.info deadlineType
      Rails.logger.info "Count:" + @@count.to_s

      if @@count%3 == 0
        assignment = Assignment.find(self.assignment_id)

        if(assignment.instructor.copy_of_emails)
          emails<< assignment.instructor.email
        end

        #emails<< "expertiza-support@lists.ncsu.edu"
      end

      emails.each do |mail|
        Rails.logger.info mail
      end

      Mailer.delayed_message(
        {:bcc => emails,
         :subject => subject,
         :body => body
      }).deliver
    end

  end

