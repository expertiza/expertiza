# Author: Andrew Kofink, 2013-09-28
class StudentTask
  include ActionView::Helpers::DateHelper
  include StudentTaskHelper
  attr_accessor :assignment, :current_stage, :participant, :stage_deadline, :topic

  delegate :course, to: :assignment
  delegate :topic, to: :participant
  delegate :response_maps, to: :participant

  def initialize(args)
    @assignment = args[:assignment]
    @current_stage = args[:current_stage]
    @participant = args[:participant]
    @stage_deadline = args[:stage_deadline]
    @topic = args[:topic]
  end

  # Attempts to get topic_name from topic, returns '-' if it doesn't exist
  def topic_name
    topic.try(:topic_name) || '-'
  end

  # Determines if stage deadline is 'Complete'
  def complete?
    stage_deadline == 'Complete'
  end

  # Determines if it's submission stage and if either hyperlinks or recent_submission is present
  def content_submitted_in_current_stage?
    current_stage == 'submission' && (hyperlinks.present? || recent_submission.present?) 
  end

  # Assigns the participant’s team hyperlinks to the @hyperlinks instance variable.
  # If the participant is not part of a team, assigns an empty array to @hyperlinks for type safety.
  def hyperlinks
    @hyperlinks ||= participant.team.nil? ? [] : participant.team.hyperlinks
  end

  # Returns participant's most recent submission, returns nil if it doesn't exist
  def recent_submission
    participant.team&.most_recent_submission
  end

  # Determines if StudentTask is not complete
  def incomplete?
    !complete?
  end

  # Checks if there are any metareviews given by evaluating response maps
  def metareviews_given?
    response_maps.inject(nil) { |i, j| i || (j.response && j.class.to_s[/Metareview/]) }
  end

  # Checks if metareviews have been given in the current stage,
  # provided the current stage is 'metareview'
  def metareviews_given_in_current_stage?
    current_stage == 'metareview' && metareviews_given?
  end

  # Determines if the StudentTask has not been started by checking
  # if it's in a work stage but hasn't yet been marked as started
  def not_started?
    in_work_stage? && !started?
  end

  # Returns the deadline for the current stage in relative time format if a stage deadline exists
  def relative_deadline
    time_ago_in_words(stage_deadline) if stage_deadline
  end

  # Checks if any reviews have been given by scanning the response maps for a response of type 'Review'
  def reviews_given?
    response_maps.inject(nil) { |i, j| i || (j.response && j.class.to_s[/Review/]) }
  end

  # Checks if reviews have been given in the current stage, provided the current stage is 'review'
  def reviews_given_in_current_stage?
    current_stage == 'review' && reviews_given?
  end

  # Determines if the task is currently in a work stage (submission, review, or metareview)
  def in_work_stage?
    current_stage == 'submission' ||
      current_stage == 'review' ||
      current_stage == 'metareview'
  end

  # Determines if a revision has occurred by checking if any content,
  # review, or metareview has been submitted in the current stage
  def revision?
    content_submitted_in_current_stage? ||
      reviews_given_in_current_stage? ||
      metareviews_given_in_current_stage?
  end

  # Checks if the task has been started, while caching the result; considers
  # a task started if it’s incomplete and there has been a revision
  def started?
    @started ||= incomplete? && revision?
  end
end
