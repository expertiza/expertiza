# frozen_string_literal: true

# This concern provides the `review_service` method, which initializes the `ReviewService`
# with the current participant. It can be included in any controller that requires review-related logic.
module ReviewServiceConcern
  extend ActiveSupport::Concern

  # Initialize review service
  def review_service
    @review_service ||= ReviewService.new(participant_service.participant)
  end
end
