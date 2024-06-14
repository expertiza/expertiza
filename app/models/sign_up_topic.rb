class SignUpTopic < ApplicationRecord
  has_many :signed_up_teams, foreign_key: 'topic_id', dependent: :destroy
  has_many :teams, through: :signed_up_teams # list all teams choose this topic, no matter in waitlist or not
  has_many :due_dates, class_name: 'TopicDueDate', foreign_key: 'parent_id', dependent: :destroy
  has_many :bids, foreign_key: 'topic_id', dependent: :destroy
  has_many :assignment_questionnaires, class_name: 'AssignmentQuestionnaire', foreign_key: 'topic_id', dependent: :destroy
  belongs_to :assignment

  has_paper_trail

  # the below relations have been added to make it consistent with the database schema
  validates :topic_name, :assignment_id, :max_choosers, presence: true
  validates :topic_identifier, length: { maximum: 10 }

  def self.import(row_hash, session, _id = nil)
    if row_hash.length < 3
      raise ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).'
    end

    topic = SignUpTopic.where(topic_name: row_hash[:topic_name], assignment_id: session[:assignment_id]).first
    if topic.nil?
      attributes = ImportTopicsHelper.define_attributes(row_hash)
      ImportTopicsHelper.create_new_sign_up_topic(attributes, session)
    else
      topic.max_choosers = row_hash[:max_choosers]
      topic.topic_identifier = row_hash[:topic_identifier]
      topic.save
    end
  end

  def get_chooser_count(assignment_id, is_waitlisted)
    # NOTE: Cannot change the inner join query unless the model has the associations setup for identifying the keys correctly.
    SignUpTopic.where(assignment_id: assignment_id).joins('INNER JOIN signed_up_teams ON sign_up_topics.topic_id = signed_up_teams.id').where('signed_up_teams.is_waitlisted = ?', is_waitlisted).group("id").count(:max_choosers)
  end

  def self.find_slots_filled(assignment_id)
    return get_chooser_count(assignment_id, false)
  end

  def self.find_slots_waitlisted(assignment_id)
    return get_chooser_count(assignment_id, true)
  end

  # NOTE: TODO: MOVE THIS TO SIGNED_UP_TEAM SINCE THIS IS A TEAM BASED ACTION.
  def self.find_waitlisted_topics(assignment_id, team_id)
    SignedUpTeam.find_by_sql(['SELECT u.id FROM sign_up_topics t, signed_up_teams u WHERE t.id = u.topic_id and u.is_waitlisted = true and t.assignment_id = ? and u.team_id = ?', assignment_id.to_s, team_id.to_s])
  end

  def self.slotAvailable?(topic_id)
    topic = SignUpTopic.find(topic_id)
    no_of_students_who_selected_the_topic = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: false)

    if no_of_students_who_selected_the_topic.nil?
      return true
    else
      return topic.max_choosers > no_of_students_who_selected_the_topic.size
    end
  end

  def self.has_suggested_topic?(assignment_id)
    sign_up_topics = SignUpTopic.where(assignment_id: assignment_id, private_to: nil)
    all_topics = SignUpTopic.where(assignment_id: assignment_id)
    sign_up_topics.size != all_topics.size
  end

  def format_for_display
    topic_display = ''
    topic_display += topic_identifier.to_s + ' - '
    topic_display + topic_name
  end

  # E2121 Line 160: Refactor approve_suggestion to indicate that notification is being sent
  def self.new_topic_from_suggestion(suggestion)
    signuptopic = SignUpTopic.new
    signuptopic.topic_identifier = 'S' + Suggestion.where('assignment_id = ? and id <= ?', suggestion.assignment_id, suggestion.id).size.to_s
    signuptopic.topic_name = suggestion.title
    signuptopic.assignment_id = suggestion.assignment_id
    signuptopic.max_choosers = 1
    # return this model based on these checks
    if signuptopic.save && suggestion.update_attribute('status', 'Approved')
      return signuptopic
    else
      return 'failed'
    end
  end
end
