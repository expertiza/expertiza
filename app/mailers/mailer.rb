class Mailer < ActionMailer::Base
  if Rails.env.development? || Rails.env.test?
    default from: 'expertiza.development@gmail.com'
  else
    default from: 'expertiza-support@lists.ncsu.edu'
  end

  def generic_message(defn)
    @partial_name = defn[:body][:partial_name]
    @user = defn[:body][:user]
    @first_name = defn[:body][:first_name]
    @password = defn[:body][:password]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end

  def request_user_message(defn)
    @user = defn[:body][:user]
    @super_user = defn[:body][:super_user]
    @first_name = defn[:body][:first_name]
    @new_pct = defn[:body][:new_pct]
    @avg_pct = defn[:body][:avg_pct]
    @assignment = defn[:body][:assignment]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:bcc])
  end

  def sync_message(defn)
    @body = defn[:body]
    @type = defn[:body][:type]
    @obj_name = defn[:body][:obj_name]
    @first_name = defn[:body][:first_name]
    @partial_name = defn[:body][:partial_name]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         # content_type: "text/html",
         to: defn[:to])
  end

  def delayed_message(defn)
    ret = mail(subject: defn[:subject],
               body: defn[:body],
               content_type: "text/html",
               to: defn[:bcc])
    ExpertizaLogger.info(ret.encoded.to_s)
    ret
  end

  def suggested_topic_approved_message(defn)
    @body = defn[:body]
    @topic_name = defn[:body][:approved_topic_name]
    @proposer = defn[:body][:proposer]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         to: defn[:to],
         bcc: defn[:cc])
  end

  def notify_member(defn)

    @body=defn[:body]
    @mentor=defn[:body][:mentor]
    @members=defn[:body][:members]
    @team=defn[:body][:team]
    @ismentor=defn[:body][:ismentor]

    mail(subject: defn[:subject],
         to: defn[:to]
    )
  end

  def notify_grade_conflict_message(defn)
    @body = defn[:body]

    @assignment = @body[:assignment]
    @reviewer_name = @body[:reviewer_name]
    @type = @body[:type]
    @reviewee_name = @body[:reviewee_name]
    @new_score = @body[:new_score]
    @conflicting_response_url = @body[:conflicting_response_url]
    @summary_url = @body[:summary_url]
    @assignment_edit_url = @body[:assignment_edit_url]

    defn[:to] = 'expertiza.development@gmail.com' if Rails.env.development? || Rails.env.test?
    mail(subject: defn[:subject],
         to: defn[:to])
  end

  # after mentor assigned, email mentor about team info(names+emails)
  #def notify_mentor(mentor,team)
  #  members = TeamsUser.where(team_id: team.id)
  #  members_name=""
  #  for i in 0..members.size-2 do
  #    members_name += " "+ members[i].fullname+", "+User.find(members[i].user_id).email+"<br>"
  #  end
  #  Mailer.delayed_message(bcc: [User.find(mentor.user_id).email],
  #                        subject: "[Expertiza]: New Team Assignment",
  #                         body: "You have been assigned as a mentor to team " + team.name + "<br>Current member:<br>"+members_name).deliver_now
  #end

  # after mentor assigned, email all current team members about mentor and team member info
  #def notify_team_members(mentor,team)
  #  ExpertizaLogger.info LoggerMessage.new('Model:Mailer', user.name, "notify team members entered")
  #  members = TeamsUser.where(team_id: team.id)
  #  members_name = ""
    # i=size-1 does not count since it will be the mentor not student
  #  for i in 0..members.size-2 do
  #    members_name += " " + members[i].fullname+", "+User.find(members[i].user_id).email+"<br>"
  #  end
  #  mentor_info=mentor.fullname + "("+User.find(mentor.user_id).email+") "
  #  members.each do |member|
  #    if member.user_id != mentor.user_id
  #      ExpertizaLogger.info LoggerMessage.new('Model:Mailer', user.name, "Delayed mailer being called")
  #      Mailer.delayed_message(bcc: [User.find(member.user_id).email],
  #                             subject: "[Expertiza]: New Mentor Assignment",
  #                             body: mentor_info+"has been assigned as your mentor for assignment "+ Assignment.find(team.parent_id).name+"<br>Current member:<br>"+members_name).deliver_now
  #    end
  #  end
  #end

  # after mentor assigned, when new member added to the team, only email new added member about mentor and team info
  def notify_single_team_member(member,mentor,team)
    members = TeamsUser.where(team_id: team.id)
    members_name = ""
    for i in 0..members.size-1 do
      if members[i].user_id !=  mentor.user_id
        members_name += " " + members[i].fullname+", "+User.find(members[i].user_id).email+"<br>"
      end
    end
    mentor_info=mentor.fullname + "("+User.find(mentor.user_id).email+") "
    Mailer.delayed_message(bcc: [member.email],
                           subject: "[Expertiza]: New Mentor Assignment",
                           body: mentor_info+"has been assigned as your mentor for assignment"+ Assignment.find(team.parent_id).name+"<br>Current member:<br>"+members_name).deliver_now
  end

end
