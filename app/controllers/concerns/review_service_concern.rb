# frozen_string_literal: true

# This concern provides the `review_service` method for the current participant.
module ReviewServiceConcern
  extend ActiveSupport::Concern

  # Initialize review service
  def review_service
    @review_service ||= ReviewService.new(participant_service.participant)
  end
end
