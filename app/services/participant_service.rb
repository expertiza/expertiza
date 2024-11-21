# frozen_string_literal: true

# The `ParticipantService` class encapsulates the business logic related to
# `AssignmentParticipant` objects. It provides methods to validate the participant,
# retrieve associated assignment details, determine the current topic ID, and fetch
# the reviewer associated with the participant.
class ParticipantService
  attr_reader :participant

  def initialize(participant_id, current_user_id)
    @participant = AssignmentParticipant.find(participant_id)
    @current_user_id = current_user_id
  end

  def valid_participant?
    return false unless @participant

    @participant.user_id == @current_user_id
  end

  def assignment
    @assignment ||= @participant&.assignment
  end

  def topic_id
    SignedUpTeam.topic_id(@participant&.parent_id, @participant&.user_id)
  end

  def reviewer
    @participant&.get_reviewer
  end

  def participant_authorization
    @participant&.authorization
  end
end
