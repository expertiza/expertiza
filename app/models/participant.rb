class Participant < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :assignment, foreign_key: 'parent_id'

  has_many   :comments, dependent: :destroy
  has_many   :reviews, class_name: 'ResponseMap', foreign_key: 'reviewer_id', dependent: :destroy
  has_many   :team_reviews, class_name: 'ReviewResponseMap', foreign_key: 'reviewer_id', dependent: :destroy
  has_many :response_maps, class_name: 'ResponseMap', foreign_key: 'reviewee_id', dependent: :destroy

  PARTICIPANT_TYPES = ['Course', 'Assignment']

  def team
    TeamsUser.where(user: user).first.try :team
  end

  def responses
    response_maps.map(&:response)
  end

  validates_numericality_of :grade, allow_nil: true

  delegate :course, to: :assignment

  has_paper_trail

  def get_current_stage
    assignment.try :get_current_stage, topic_id
  end

  def stage_deadline
    assignment.stage_deadline topic_id
  end

  def name
    User.find(self.user_id).name
  end

  def fullname
    User.find(self.user_id).fullname
  end

  def delete(force = nil)
    # TODO: How do we test this code?  #need a controller test_oss808
    maps = ResponseMap.where(['reviewee_id = ? or reviewer_id = ?', self.id, self.id])

    if force or ((maps.nil? or maps.empty?) and
                 self.team.nil?)
      force_delete(maps)
    else
      raise "Associations exist for this participant."
    end
    end

  def force_delete(maps)
    maps.each { |map| map.delete(true) } if maps

    if self.team
      if self.team.teams_users.length == 1
        self.team.delete
      else
        self.team.teams_users.each do |tuser|
          tuser.delete if tuser.user_id == self.id
        end
      end
    end
    self.destroy
  end

  def topic_name
    return "<center>&#8212;</center>" if topic.nil? or topic.topic_name.empty?
    topic.topic_name
  end

  def able_to_review
    return true if can_review
    false
  end

    # email does not work. It should be made to work in the future
  def email(pw, home_page)
    user = User.find(self.user_id)
    assignment = Assignment.find(self.assignment_id)

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

    if self.assignment.varying_rubrics_by_round? # for "vary rubric by rounds" feature -Yang
      self.assignment.questionnaires.each do |questionnaire|
        round = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(self.assignment.id, questionnaire.id).used_in_round
        questionnaire_symbol = if (!round.nil?)
          (questionnaire.symbol.to_s+round.to_s).to_sym
        else
          questionnaire.symbol
                               end
        scores[questionnaire_symbol] = {}
        scores[questionnaire_symbol][:assessments] = questionnaire.get_assessments_for(self)
        scores[questionnaire_symbol][:scores] = Answer.compute_scores(scores[questionnaire_symbol][:assessments], questions[questionnaire_symbol])
      end

    else # not using "vary rubric by rounds" feature
      self.assignment.questionnaires.each do |questionnaire|
        scores[questionnaire.symbol] = {}
        scores[questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(self)

        scores[questionnaire.symbol][:scores] = Answer.compute_scores(scores[questionnaire.symbol][:assessments], questions[questionnaire.symbol])
      end
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
    if can_submit == false and can_review == true and can_take_quiz == true
      authorization = 'reader'
    end
    if can_submit == true and can_review == false and can_take_quiz == false
      authorization = 'submitter'
    end
    if can_submit == false and can_review == true and can_take_quiz == false
      authorization = 'reviewer'
    end
    authorization
  end

  # Sort a set of participants based on their user names.
  # Please make sure there is no duplicated participant in this input array.
  # There should be a more beautiful way to handle this, though.  -Yang
  def self.sort_by_name(participants)
    users = []
    participants.each do |participant|
      user = User.find(participant.user_id)
      users << user
    end
    users.sort! {|a, b| a.name.downcase <=> b.name.downcase } # Sort the users based on the name

    sorted_user_ids = users.map {|u| u.id }
    sorted_participants = participants.sort_by {|x| sorted_user_ids.index x.user_id }

    sorted_participants
  end
end
