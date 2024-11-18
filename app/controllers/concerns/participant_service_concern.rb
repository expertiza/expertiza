# frozen_string_literal: true

# This concern provides the `participant_service` method and related participant-specific logic.
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
