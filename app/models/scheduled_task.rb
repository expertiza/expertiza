class ScheduledTask
  # Keeps info required for delayed job
  # to perform an action at a particular time
  # such as sending a reminder email, or dropping outstanding review
  attr_accessor :assignment_id
  attr_accessor :deadline_type
  attr_accessor :due_at
  @@count = 0
  def initialize(assignment_id, deadline_type, due_at)
    self.assignment_id = assignment_id
    self.deadline_type = deadline_type
    self.due_at = due_at
  end

  def perform
    assignment = Assignment.find(self.assignment_id)
    if !assignment.nil? && !assignment.id.nil?
      if (self.deadline_type == "metareview")
        mail_metareviewers
        if assignment.team_assignment?
          teamMails = getTeamMembersMail
          email_reminder(teamMails, "teammate review")
        end
      end

      if (self.deadline_type == "review")
        mail_reviewers # to all reviewers
      end

      if (self.deadline_type == "submission")
        mail_signed_up_users # to all signed up users
      end

      if (self.deadline_type == "drop_topic")
        sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])
        if (!sign_up_topics.nil? && sign_up_topics.count != 0)
          mail_signed_up_users # reminder to signed_up users of the assignment
        end
      end

      if (self.deadline_type == "signup")
        sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])
        if (!sign_up_topics.nil? && sign_up_topics.count != 0)
          mail_assignment_participants # reminder to all participants
        end
      end

      if (self.deadline_type == "team_formation")
        assignment = Assignment.find(self.assignment_id)
        if (assignment.team_assignment?)
          emails = get_one_member_team
          email_reminder(emails, self.deadline_type)
        end
      end

      if (self.deadline_type == "drop_one_member_topics")
        assignment = Assignment.find(self.assignment_id)
        drop_one_member_topics if (assignment.team_assignment?)
      end

      if (self.deadline_type == "drop_outstanding_reviews")
        drop_outstanding_reviews
      end
      if (self.deadline_type == "compare_files_with_simicheck")
        compare_files_with_simicheck # to all reviewers
      end
    end
  end

  def mail_signed_up_users
    emails = []
    assignment = Assignment.find(self.assignment_id)
    sign_up_topics = SignUpTopic.where(['assignment_id = ?', self.assignment_id])

    # If there are sign_up topics for an assignement then send a mail toonly signed_up_teams else send a mail to all participants
    if (sign_up_topics.nil? || sign_up_topics.count == 0)
      if assignment.team_assignment?
        teamMails = getTeamMembersMail
        for mail in teamMails
          emails << mail
          email_reminder(emails, self.deadline_type)
        end
      else
        mail_assignment_participants
      end
    else
      for topic in sign_up_topics
        signedUpTeams = SignedUpTeam.where(['topic_id = ?', topic.id])
        unless assignment.team_assignment?
          for signedUser in signedUpTeams
            uid  = signedUser.team_id
            user = User.find(uid)
            emails << user.email
          end
        else
          for signedUser in signedUpTeams
            teamid = signedUser.team_id
            team_members = TeamsUser.where(team_id: teamid)
            for team_member in team_members
              user = User.find(team_member.user_id)
              emails << user.email
            end
          end
        end
      end
      email_reminder(emails, self.deadline_type) if emails.size > 0
    end
  end

  def getTeamMembersMail
    teamMembersMailList = []
    assignment = Assignment.find(self.assignment_id)
    teams = Team.where(['parent_id = ?', self.assignment_id])
    for team in teams
      team_participants = TeamsUser.where(['team_id = ?', team.id])
      for team_participant in team_participants
        user = User.find(team_participant.user_id)
        teamMembersMailList << user.email
      end
    end
    teamMembersMailList
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
        participant = Participant.where(['parent_id = ? AND id = ?', self.assignment_id, metareviewer.reviewer_id]).first
        uid  = participant.user_id
        user = User.find(uid)
        emails << user.email
      end
    end
    email_reminder(emails, self.deadline_type) if emails.size > 0
  end

  def mail_reviewers
    emails = []
    reviewer_tuples = ResponseMap.where(['reviewed_object_id = ? AND type = "ReviewResponseMap"', self.assignment_id])
    for reviewer in reviewer_tuples
      participant = Participant.where(['parent_id = ? AND id = ?', self.assignment_id, reviewer.reviewer_id])
      uid  = participant.first.user_id
      user = User.find(uid)
      emails << user.email
    end
    email_reminder(emails, self.deadline_type) if emails.size > 0
  end

  def mail_assignment_participants
    emails = []
    assignment = Assignment.find(self.assignment_id)
    for participant in assignment.participants
      uid = participant.user_id
      user = User.find(uid)
      emails << user.email
    end
    email_reminder(emails, self.deadline_type)
  end

  def email_reminder(emails, deadlineType)
    assignment = Assignment.find(self.assignment_id)
    subject = "Message regarding #{deadlineType} for assignment #{assignment.name}"
    body = "This is a reminder to complete #{deadlineType} for assignment #{assignment.name}. Deadline is #{self.due_at}.If you have already done the  #{deadlineType}, Please ignore this mail."

    # emails<<"vikas.023@gmail.com"
    # emails<<"vsharma4@ncsu.edu"
    @@count += 1
    Rails.logger.info "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    Rails.logger.info deadlineType
    Rails.logger.info "Count:" + @@count.to_s

    if @@count % 3 == 0
      assignment = Assignment.find(self.assignment_id)

      if (assignment.instructor.copy_of_emails)
        emails << assignment.instructor.email
      end

      # emails<< "expertiza-support@lists.ncsu.edu"
    end

    emails.each do |mail|
      Rails.logger.info mail
    end

    Mailer.delayed_message(
      bcc: emails,
       subject: subject,
       body: body
).deliver
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
#method which runs after x hours of assignment submission which creates different simicheck comparisons and submits all files/links to that comparison
  def compare_files_with_simicheck
    comparison_file = SimicheckComparison.create_simicheck_comparison(self.assignment_id,"file")
    comparison_html = SimicheckComparison.create_simicheck_comparison(self.assignment_id,"html")
    comparison_gdoc = SimicheckComparison.create_simicheck_comparison(self.assignment_id,"gdoc")
    comparison_github = SimicheckComparison.create_simicheck_comparison(self.assignment_id,"github")
    assignment = Assignment.find(self.assignment_id)
    assignment_teams = AssignmentTeam.where(['parent_id = ?', self.assignment_id])

    for assignment_team in assignment_teams
      if assignment_team.has_submissions?
        hyperlinks = assignment_team.hyperlinks
        link_count = 1 #to keep track of the number of hyperlinks submitted
        for link in hyperlinks
          if(link.include?('github.com'))
            user = link.partition('.com/').last.split('/')[0]
            repo = link.partition('.com/').last.split('/')[1]
            #client = Octokit::Client.new(:login=>'ssn0602',:password=>'a1b2c3d4')
            client = Octokit::Client.new(:login=>'expertizaSimicheck',:password=>'expertiza123')
            path = user + '/' + repo
            assignment_commits = client.commits_between(path,(DateTime.parse(self.due_at)-45.days).to_date.to_s,(DateTime.parse(self.due_at)).to_date.to_s)
            l = assignment_commits.length
            commit_files = Array.new(l)
            0.upto(l-1).each {  |i|
              commit_url = assignment_commits[i][:url]
              commit_json = RestClient.get(commit_url)
              commit_hash = JSON.parse(commit_json)
              num_of_files = commit_hash["files"].length
              f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".txt", "a")
              0.upto(num_of_files -1).each { |j|
                if (commit_hash["files"][j] != nil)
                   commited_patch = commit_hash["files"][j]["patch"]
                   f.write(commited_patch)
                end
              }
              f.close
            }
            f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".txt", "r")
            comparison_github.send_file_to_simicheck(f)
            link_count += 1
          elsif(link.include?('docs.google.com'))
            doc_id = link.partition('/d/').last.split('/')[0]
            doc_url = "https://docs.google.com/document/d/"+doc_id+"/export?format=docx"
            response = RestClient.get(doc_url)
            if(response.code == 200)
              page = response.body
              f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".docx", "wb+")
              f.write(page)
              f.close
              f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".docx", "r")
              comparison_gdoc.send_file_to_simicheck(f)
              link_count += 1
              #f.close
            end
          else
            response = RestClient.get(link)
            if(response.code == 200)
              page = response.body
              f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".html", "w+")
              f.write(page)
              f.close
              f = File.open("/tmp/"+assignment_team.name+"_#{link_count}"+".html", "r")
              comparison_html.send_file_to_simicheck(f)
              link_count += 1
              #f.close
            end
          end
        end
      end
      if assignment_team.directory_num
        files = assignment_team.files(assignment_team.path)
        for path in files
            f = File.open(path, "r")
            comparison_file.send_file_to_simicheck(f)
            #f.close
        end
      end
      end
  end

  def drop_outstanding_reviews
    reviews = ResponseMap.where(reviewed_object_id: self.assignment_id )
    for review in reviews
      review_has_began = Response.where(map_id: review.id)
      if review_has_began.size.zero?
        review_to_drop = ResponseMap.where(id: review.id)
        review_to_drop.first.destroy
      end
    end
  end
end
