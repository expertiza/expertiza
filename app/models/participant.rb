class Participant < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :assignment, foreign_key: 'parent_id'
  has_many   :join_team_requests, dependent: :destroy
  has_many   :reviews, class_name: 'ResponseMap', foreign_key: 'reviewer_id', dependent: :destroy
  has_many   :team_reviews, class_name: 'ReviewResponseMap', foreign_key: 'reviewer_id', dependent: :destroy
  has_many :response_maps, class_name: 'ResponseMap', foreign_key: 'reviewee_id', dependent: :destroy
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
    if force or (maps.blank? and self.team.nil?)
      force_delete(maps)
    else
      raise "Associations exist for this participant."
    end
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
    assignment = Assignment.find_by(id: self.assignment_id)

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
  def scores(questions)
    scores = {}
    scores[:participant] = self
    self.assignment.questionnaires.each do |questionnaire|
      round = AssignmentQuestionnaire.find_by(assignment_id: self.assignment.id, questionnaire_id: questionnaire.id).used_in_round
      questionnaire_symbol = if round
                               (questionnaire.symbol.to_s + round.to_s).to_sym
                             else
                               questionnaire.symbol
                             end
      scores[questionnaire_symbol] = {}
      scores[questionnaire_symbol][:assessments] = questionnaire.get_assessments_for(self)
      scores[questionnaire_symbol][:scores] = Answer.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
    end
    scores[:total_score] = assignment.compute_total_score(scores)
    scores
  end

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
end
