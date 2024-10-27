class Participant < ApplicationRecord
  include Scoring
  include ParticipantsHelper
  has_paper_trail
  belongs_to :user
  belongs_to :topic, class_name: 'SignUpTopic', inverse_of: false
  belongs_to :assignment, foreign_key: 'parent_id', inverse_of: false
  has_many   :join_team_requests, dependent: :destroy
  has_many   :reviews, class_name: 'ResponseMap', foreign_key: 'reviewer_id', dependent: :destroy, inverse_of: false
  has_many   :team_reviews, class_name: 'ReviewResponseMap', foreign_key: 'reviewer_id', dependent: :destroy, inverse_of: false
  has_many :response_maps, class_name: 'ResponseMap', foreign_key: 'reviewee_id', dependent: :destroy, inverse_of: false
  has_many :awarded_badges, dependent: :destroy
  has_many :badges, through: :awarded_badges
  has_one :review_grade, dependent: :destroy
  validates :grade, numericality: { allow_nil: true }
  has_paper_trail
  delegate :course, to: :assignment
  delegate :current_stage, to: :assignment
  delegate :stage_deadline, to: :assignment

  PARTICIPANT_TYPES = %w[Course Assignment].freeze

  # define a constant to hold the duty title Mentor
  # this will be used in the duty column of the participant
  # table to define participants who can mentor teams, topics, or assignments
  # since the column's type is VARCHAR(255), other string constants should be
  # defined here to add different duty titles
  DUTY_MENTOR = 'mentor'.freeze

  def team
    TeamsUser.find_by(user: user).try(:team)
  end

  def responses
    response_maps.map(&:response)
  end

  def name(ip_address = nil)
    user.username(ip_address)
  end

  def fullname(ip_address = nil)
    user.fullname(ip_address)
  end

  def handle(ip_address = nil)
    User.anonymized_view?(ip_address) ? 'handle' : self[:handle]
  end

  def delete(force = nil)
    maps = ResponseMap.where('reviewee_id = ? or reviewer_id = ?', id, id)

    raise 'Associations exist for this participant.' unless force || (maps.blank? && team.nil?)

    force_delete(maps)
  end

  def force_delete(maps)
    maps && maps.each(&:destroy)
    if team && (team.teams_users.length == 1)
      team.delete
    elsif team
      team.teams_users.each { |teams_user| teams_user.destroy if teams_user.user_id == id }
    end
    destroy
  end

  def topic_name
    if topic.nil? || topic.topic_name.empty?
      '<center>&#8212;</center>' # em dash
    else
      topic.topic_name
    end
  end

  # send email to team's reviewers in case a new submission is made
  def mail_assigned_reviewers
    # Find review mappings for the work done by this participant's team
    mappings = ResponseMap.where(reviewed_object_id: self.assignment.id,
                                 reviewee_id: self.team.id,
                                 type: 'ReviewResponseMap')
    unless mappings.nil?
      mappings.each do |mapping|
        reviewer = mapping.reviewer.user
        prepared_mail = MailerHelper.send_mail_to_assigned_reviewers(reviewer, self, mapping)
        prepared_mail.deliver_now
      end
    end
  end

  def able_to_review
    can_review
  end

  def email(pw, home_page)
    user = User.find_by(id: user_id)
    assignment = Assignment.find_by(id: self.assignment.id)

    Mailer.sync_message(
      recipients: user.email,
      subject: "You have been registered as a participant in the Assignment #{assignment.name}",
      body: {
        home_page: home_page,
        first_name: ApplicationHelper.get_user_first_name(user),
        name: user.username,
        password: pw,
        partial_name: 'register'
      }
    ).deliver
  end

  # Get authorization from permissions.
  def authorization
    authorization = 'participant'
    #E2351 - need to change authorization to reflect mentor when importing
    #otherwise all imported Assignment Participants would be 'participant' even if designated as mentor in import file
    authorization = 'mentor' if can_mentor
    authorization = 'reader' if !can_submit && can_review && can_take_quiz
    authorization = 'submitter' if can_submit && !can_review && !can_take_quiz
    authorization = 'reviewer' if !can_submit && can_review && !can_take_quiz
    authorization
  end

  # Sort a set of participants based on their user names.
  # Please make sure there is no duplicated participant in this input array.
  # There should be a more beautiful way to handle this, though.  -Yang
  def self.sort_by_name(participants)
    users = []
    participants.each { |p| users << p.user }
    users.sort! { |a, b| a.username.downcase <=> b.username.downcase } # Sort the users based on the name
    participants.sort_by { |p| users.map(&:id).index(p.user_id) }
  end

  # provide export functionality for Assignment Participants and Course Participants
  def self.export(csv, parent_id, options)
    where(parent_id: parent_id).find_each do |part|
      tcsv = []
      user = part.user
      tcsv.push(user.username, user.fullname, user.email) if options['personal_details'] == 'true'
      tcsv.push(user.role.name) if options['role'] == 'true'
      tcsv.push(user.parent.username) if options['parent'] == 'true'
      tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review) if options['email_options'] == 'true'
      tcsv.push(part.handle) if options['handle'] == 'true'
      csv << tcsv
    end
  end

  def self.export_fields(options)
    fields = []
    fields.push('name', 'full name', 'email') if options['personal_details'] == 'true'
    fields.push('role') if options['role'] == 'true'
    fields.push('parent') if options['parent'] == 'true'
    fields.push('email on submission', 'email on review', 'email on metareview') if options['email_options'] == 'true'
    fields.push('handle') if options['handle'] == 'true'
    fields
  end
end

