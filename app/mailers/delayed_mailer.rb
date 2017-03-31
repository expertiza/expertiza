class DelayedMailer
  # Keeps info required for delayed job
  # to perform an action at a particular time
  # such as sending a reminder email, or dropping outstanding review
  attr_accessor :assignment_id
  attr_accessor :deadline_type
  attr_accessor :due_at
  attr_accessor :mail
  @@count = 0

  def initialize(assignment_id, deadline_type, due_at)
    self.assignment_id = assignment_id
    self.deadline_type = deadline_type
    self.due_at = due_at
  end

  def find_assignment
    Assignment.find(self.assignment_id)
  end

  def sign_up_topics?
    sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])
    (!sign_up_topics.nil? && sign_up_topics.count != 0)
  end

  def perform
    assignment = find_assignment
    if !assignment.nil? && !assignment.id.nil?
      if self.deadline_type == "metareview"
        mail_metareviewers
        team_mails = find_team_members_email
        email_reminder(team_mails, "teammate review") unless team_mails.empty?
      end

      if self.deadline_type == "review"
        mail_reviewers # to all reviewers
      end

      if self.deadline_type == "submission"
        mail_signed_up_users # to all signed up users
      end

      if self.deadline_type == "drop_topic"
        if sign_up_topics?
          mail_signed_up_users # reminder to signed_up users of the assignment
        end
      end

      if self.deadline_type == "signup"
        if sign_up_topics?
          mail_assignment_participants # reminder to all participants
        end
      end

      if self.deadline_type == "team_formation"
        emails = get_one_member_team
        email_reminder(emails, self.deadline_type)
      end

      if self.deadline_type == "drop_one_member_topics"
        drop_one_member_topics if assignment.team_assignment?
      end

      if self.deadline_type == "drop_outstanding_reviews"
        drop_outstanding_reviews
      end
    end
  end

  def mail_signed_up_users
    emails = []
    sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])
    emails = if sign_up_topics.nil? || sign_up_topics.count.zero?
               find_team_members_email
             else
               find_team_members_email_for_all_topics(sign_up_topics)
             end
    email_reminder(emails, self.deadline_type) if emails and !emails.empty?
  end

  def find_team_members_email
    emails = []
    teams = Team.where(['parent_id = ?', self.assignment_id])
    for team in teams
      for team_member in team.users
        emails << team_member.email
      end
    end
    emails
  end

  def find_team_members_email_for_all_topics(sign_up_topics)
    emails = []
    sign_up_topics = [sign_up_topics] unless sign_up_topics.respond_to?(:each)
    for sign_up_topic in sign_up_topics
      for signed_up_team in sign_up_topic.signed_up_teams
        for user in signed_up_team.team.users
          emails << user.email
        end
      end
    end
    emails
  end

  def get_one_member_team
    mailList = []
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    for team_id in teams.keys
      next unless teams[team_id] == 1
      user_id = TeamsUser.where(team_id: team_id).first.user_id
      email = User.find(user_id).email
      mailList << email
    end
    mailList
  end

  def mail_metareviewers
    emails = []
    # find reviewers for the assignment
    reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "ReviewResponseMap"', self.assignment_id])
    for reviewer in reviewer_tuples
      # find metareviewers - people who will review the reviewers
      meta_reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "MetareviewResponseMap"', reviewer.id])
      for metareviewer in meta_reviewer_tuples
        emails << metareviewer.reviewer.user.email
      end
    end
    email_reminder(emails, self.deadline_type) unless emails.empty?
  end

  def mail_reviewers
    emails = []
    reviews = ResponseMap.where(['reviewed_object_id = ? AND type = "ReviewResponseMap"', self.assignment_id])
    for review in reviews
      participant = Participant.where(['parent_id = ? AND id = ?', self.assignment_id, review.reviewer_id]).first
      emails << participant.user.email
    end
    email_reminder(emails, self.deadline_type) unless emails.empty?
  end

  def mail_assignment_participants
    emails = []
    for user in find_assignment.users
      emails << user.email
    end
    email_reminder(emails, self.deadline_type)
  end

  def email_reminder(emails, deadlineType)
    assignment = find_assignment
    subject = "Message regarding #{deadlineType} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadlineType} for assignment #{assignment.name}. Deadline is #{self.due_at}.If you have already done the  #{deadlineType}, Please ignore this mail."

    @@count += 1
    Rails.logger.info "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    Rails.logger.info deadlineType
    Rails.logger.info "Count:" + @@count.to_s

    if @@count % 3 == 0
      if (assignment.instructor.copy_of_emails)
        emails << assignment.instructor.email
      end

      # emails<< "expertiza-support@lists.ncsu.edu"
    end

    emails.each do |mail|
      Rails.logger.info mail
    end

    @mail = Mailer.delayed_message(bcc: emails, subject: subject, body: body)
    @mail.deliver_now
  end

  def drop_one_member_topics
    teams = TeamsUser.all.group(:team_id).count(:team_id)
    for team_id in teams.keys
      if teams[team_id] == 1
        topic_to_drop = SignedUpTeam.where(team_id: team_id).first
        topic_to_drop.delete if topic_to_drop #check if the one-person-team has signed up a topic
      end
    end
  end

  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: self.assignment_id)
    for review in reviews
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
        review_to_drop.first.destroy
      end
    end
  end
end
