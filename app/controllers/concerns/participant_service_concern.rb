# frozen_string_literal: true

# This concern provides the `participant_service` method.
module ParticipantServiceConcern
  extend ActiveSupport::Concern

  # Initialize participant service
  def participant_service
    @participant_service ||= ParticipantService.new(params[:id], current_user.id)
  end
end
