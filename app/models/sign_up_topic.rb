class SignUpTopic < ActiveRecord::Base
  has_many :signed_up_teams, foreign_key: 'topic_id', dependent: :destroy
  has_many :teams, through: :signed_up_teams # list all teams choose this topic, no matter in waitlist or not
  has_many :due_dates, class_name: 'TopicDueDate', foreign_key: 'parent_id', dependent: :destroy
  has_many :bids, foreign_key: 'topic_id', dependent: :destroy
  has_many :assignment_questionnaires, class_name: 'AssignmentQuestionnaire', foreign_key: 'topic_id', dependent: :destroy
  belongs_to :assignment

  has_paper_trail

  # the below relations have been added to make it consistent with the database schema
  validates :topic_name, :assignment_id, :max_choosers, presence: true
  validates :topic_identifier, length: {maximum: 10}

  # This method is not used anywhere
  # def get_team_id_from_topic_id(user_id)
  #  return find_by_sql("select t.id from teams t,teams_users u where t.id=u.team_id and u.user_id = 5");
  # end

  def self.import(row_hash, session, _id = nil)
    if row_hash.length < 3
      raise ArgumentError, "The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional)."
    end
    topic = SignUpTopic.where(topic_name: row_hash[:topic_name], assignment_id: session[:assignment_id]).first
    if topic.nil?
      attributes = ImportTopicsHelper.define_attributes(row_hash)

      ImportTopicsHelper.create_new_sign_up_topic(attributes, session)
    else
      topic.max_choosers = row_hash[:max_choosers]
      topic.topic_identifier = row_hash[:topic_identifier]
      # topic.assignment_id = session[:assignment_id]
      topic.save
    end
  end

  def self.slotAvailable?(topic_id)
    topic = SignUpTopic.find(topic_id)
    no_of_students_who_selected_the_topic = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: false)

    unless no_of_students_who_selected_the_topic.nil?
      if topic.max_choosers > no_of_students_who_selected_the_topic.size
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def self.reassign_topic(session_user_id, assignment_id, topic_id)
    # find whether assignment is team assignment
    assignment = Assignment.find(assignment_id)

    # making sure that the drop date deadline hasn't passed
    dropDate = AssignmentDueDate.where(parent_id: assignment.id, deadline_type_id: '6').first
    unless dropDate.nil? || dropDate.due_at >= Time.now
      # flash[:error] = "You cannot drop this topic because the drop deadline has passed."
    else
      # if team assignment find the creator id from teamusers table and teams
      # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      # users_team will contain the team id of the team to which the user belongs
      users_team = SignedUpTeam.find_team_users(assignment_id, session_user_id)
      signup_record = SignedUpTeam.where(topic_id: topic_id, team_id:  users_team[0].t_id).first
      assignment = Assignment.find(assignment_id)
      # if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
      unless assignment.is_intelligent?
        unless signup_record.try(:is_waitlisted)
          # find the first wait listed user if exists
          first_waitlisted_user = Waitlist.first_waitlisted_user(topic_id)

          unless first_waitlisted_user.nil?
            # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
            ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
            first_waitlisted_user.is_waitlisted = false
            first_waitlisted_user.save

            # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
            # to treat all assignments as team assignments
            Waitlist.cancel_all_waitlists(first_waitlisted_user.team_id, assignment_id)
            end
        end
      end
      signup_record.destroy unless signup_record.nil?
      ExpertizaLogger.info LoggerMessage.new('SignUpTopic', session_user_id, "Topic dropped: #{topic_id}")
    end # end condition for 'drop deadline' check
  end

  def self.has_suggested_topic?(assignment_id)
    sign_up_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: nil)
    all_topics = SignUpTopic.where(assignment_id: assignment_id)
    sign_up_topics.size != all_topics.size
  end

  def users_on_waiting_list
    waitlisted_signed_up_teams = Waitlist.waitlisted_signed_up_team(self.id)
    waitlisted_users = []
    if waitlisted_signed_up_teams.present?
      waitlisted_signed_up_teams.each do |waitlisted_signed_up_team|
        assignment_team = AssignmentTeam.find(waitlisted_signed_up_team.team_id)
        waitlisted_users << assignment_team.users
      end
    end
    waitlisted_users.flatten
  end

  def format_for_display
    topic_display = ''
    topic_display += self.topic_identifier.to_s + ' - '
    topic_display + self.topic_name
  end
end
