# frozen_string_literal: true

# This concern provides the `participant_service` method and related participant-specific logic,
# such as authorization checks. It can be included in any controller that requires access to
# a participant's service logic.
module ParticipantServiceConcern
  extend ActiveSupport::Concern

  # Initialize participant service
  def participant_service
    @participant_service ||= ParticipantService.new(params[:id], current_user.id)
  end

  private

  # Check if the user is a valid participant
  def authorize_participant
    head :forbidden unless participant_service.valid_participant?
  end
end
