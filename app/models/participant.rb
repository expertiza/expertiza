class Participant < ActiveRecord::Base
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
  validates :grade, numericality: {allow_nil: true}
  has_paper_trail
  delegate :course, to: :assignment
  delegate :get_current_stage, to: :assignment
  delegate :stage_deadline, to: :assignment

  PARTICIPANT_TYPES = %w[Course Assignment].freeze

  def team
    TeamsUser.find_by(user: user).try(:team)
  end

  def responses
    response_maps.map(&:response)
  end

  def name(ip_address = nil)
    self.user.name(ip_address)
  end

  def fullname(ip_address = nil)
    self.user.fullname(ip_address)
  end

  def handle(ip_address = nil)
    User.anonymized_view?(ip_address) ? 'handle' : self[:handle]
  end

  def delete(force = nil)
    maps = ResponseMap.where('reviewee_id = ? or reviewer_id = ?', self.id, self.id)

    raise "Associations exist for this participant." unless force or (maps.blank? and self.team.nil?)
    force_delete(maps)
  end

  def force_delete(maps)
    maps and maps.each(&:destroy)
    if self.team and self.team.teams_users.length == 1
      self.team.delete
    elsif self.team
      self.team.teams_users.each {|teams_user| teams_user.destroy if teams_user.user_id == self.id }
    end
    self.destroy
  end

  def topic_name
    if topic.nil? or topic.topic_name.empty?
      "<center>&#8212;</center>" # em dash
    else
      topic.topic_name
    end
  end

  def able_to_review
    can_review
  end

  def email(pw, home_page)
    user = User.find_by(id: self.user_id)
    assignment = Assignment.find_by(id: self.assignment.id)

    Mailer.sync_message(
      recipients: user.email,
      subject: "You have been registered as a participant in the Assignment #{assignment.name}",
      body: {
        home_page: home_page,
        first_name: ApplicationHelper.get_user_first_name(user),
        name: user.name,
        password: pw,
        partial_name: "register"
      }
    ).deliver
  end

  # Return scores that this participant for the given questions
  # Implemented in assignment_participant.rb
  def scores(questions); end

  # Authorizations are paricipant, reader, reviewer, submitter (They are not store in Participant table.)
  # Permissions are can_submit, can_review, can_take_quiz.
  # Get permissions form authorizations.
  def self.get_permissions(authorization)
    can_submit = true
    can_review = true
    can_take_quiz = true
    case authorization
    when 'reader'
      can_submit = false
    when 'reviewer'
      can_submit = false
      can_take_quiz = false
    when 'submitter'
      can_review = false
      can_take_quiz = false
    end
    {can_submit: can_submit, can_review: can_review, can_take_quiz: can_take_quiz}
  end

  # Get authorization from permissions.
  def self.get_authorization(can_submit, can_review, can_take_quiz)
    authorization = 'participant'
    authorization = 'reader' if can_submit == false and can_review == true and can_take_quiz == true
    authorization = 'submitter' if can_submit == true and can_review == false and can_take_quiz == false
    authorization = 'reviewer' if can_submit == false and can_review == true and can_take_quiz == false
    authorization
  end

  # Sort a set of participants based on their user names.
  # Please make sure there is no duplicated participant in this input array.
  # There should be a more beautiful way to handle this, though.  -Yang
  def self.sort_by_name(participants)
    users = []
    participants.each {|p| users << p.user }
    users.sort! {|a, b| a.name.downcase <=> b.name.downcase } # Sort the users based on the name
    participants.sort_by {|p| users.map(&:id).index(p.user_id) }
  end

  # provide export functionality for Assignment Participants and Course Participants
  def self.export(csv, parent_id, options)
    where(parent_id: parent_id).find_each do |part|
      tcsv = []
      user = part.user
      tcsv.push(user.name, user.fullname, user.email) if options["personal_details"] == "true"
      tcsv.push(user.role.name) if options["role"] == "true"
      tcsv.push(user.parent.name) if options["parent"] == "true"
      tcsv.push(user.email_on_submission, user.email_on_review, user.email_on_review_of_review) if options["email_options"] == "true"
      tcsv.push(part.handle) if options["handle"] == "true"
      csv << tcsv
    end
  end

  def self.export_fields(options)
    fields = []
    fields.push("name", "full name", "email") if options["personal_details"] == "true"
    fields.push("role") if options["role"] == "true"
    fields.push("parent") if options["parent"] == "true"
    fields.push("email on submission", "email on review", "email on metareview") if options["email_options"] == "true"
    fields.push("handle") if options["handle"] == "true"
    fields
  end

  def self.createparticipant(matt,old_assign, new_assign_id)
    @old_participant = Participant.where(user_id: matt.user_id, parent_id: old_assign.id)
    @old_participant.each do |natt|
      @new_participant = Participant.new
      @new_participant.can_submit = natt.can_submit
      @new_participant.can_review = natt.can_review
      @new_participant.user_id = matt.user_id
      @new_participant.parent_id = new_assign_id
      @new_participant.submitted_at = natt.submitted_at
      @new_participant.permission_granted = natt.permission_granted
      @new_participant.penalty_accumulated = natt.penalty_accumulated
      @new_participant.grade = natt.grade
      @new_participant.type = natt.type
      @new_participant.handle = natt.handle
      @new_participant.time_stamp = natt.time_stamp
      @new_participant.digital_signature = natt.digital_signature
      @new_participant.duty = natt.duty
      @new_participant.can_take_quiz = natt.can_take_quiz
      @new_participant.save
    end
  end

  def self.mapreviewresponseparticipant(old_assign, new_assign_id, dict)
    @old_assignmentnumber = Assignment.find_by(id: old_assign.id)
    @new_assignmentnumber = Assignment.find_by(id: new_assign_id)
    @find_participant = Participant.find_by(parent_id: old_assign.id, user_id: @old_assignmentnumber.instructor_id)
    @new_participant = Participant.new
    @new_participant.can_submit = @find_participant.can_submit
    @new_participant.can_review = @find_participant.can_review
    @new_participant.user_id = @new_assignmentnumber.instructor_id
    @new_participant.parent_id = new_assign_id
    @new_participant.submitted_at = @find_participant.submitted_at
    @new_participant.permission_granted = @find_participant.permission_granted
    @new_participant.penalty_accumulated = @find_participant.penalty_accumulated
    @new_participant.grade = @find_participant.grade
    @new_participant.type = @find_participant.type
    @new_participant.handle = @find_participant.handle
    @new_participant.time_stamp = @find_participant.time_stamp
    @new_participant.digital_signature = @find_participant.digital_signature
    @new_participant.duty = @find_participant.duty
    @new_participant.can_take_quiz = @find_participant.can_take_quiz
    @new_participant.save
    @getnewparticipant = Participant.find_by(parent_id: new_assign_id, user_id: @old_assignmentnumber.instructor_id)
    @old_reviewrespmap = ReviewResponseMap.where(reviewed_object_id: old_assign.id)
    @old_reviewrespmap.each do |satt|
      if dict.key?(satt.reviewee_id)
        @new_reviewrespmap = ReviewResponseMap.new
        @new_reviewrespmap.reviewed_object_id = new_assign_id
        @new_reviewrespmap.reviewer_id = @getnewparticipant.id
        @new_reviewrespmap.reviewee_id = dict[satt.reviewee_id]
        @new_reviewrespmap.type = satt.type
        @new_reviewrespmap.created_at = satt.created_at
        @new_reviewrespmap.calibrate_to = satt.calibrate_to
        @new_reviewrespmap.save
      else
        next
      end
    end
  end

end
