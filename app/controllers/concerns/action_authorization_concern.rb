# frozen_string_literal: true

# The `ActionAuthorizationConcern` module provides shared authorization logic
# for controllers that require role-based access checks for specific actions.
# It defines the `action_authorized?` method, which checks whether the necessary
# authorizations are present for a given action and assignment.
#
# Including controllers must implement the `required_authorizations_for_action` method
# to define the authorizations needed for the actions within their specific context.
module ActionAuthorizationConcern
  extend ActiveSupport::Concern

  private

  def authorize_action
    return unless action_allowed?

    render plain: 'Access Denied', status: :forbidden
  end

  def authorize_participant
    head :forbidden unless participant_service.valid_participant?
  end

  def action_allowed?
    return false unless current_user

    action = params[:action].to_s.downcase
    assignment = participant_service.assignment

    return verify_authorizations(assignment) if actions_requiring_authorization.include?(action)
    return verify_action_access(assignment) if actions_allowed_for_students_and_above.include?(action)
    return current_user_has_ta_privileges? if actions_restricted_to_tas_and_above.include?(action)

    false
  end

  def verify_authorizations
    raise NotImplementedError, "#{self.class.name} must define #verify_authorization"
  end

  def verify_action_access(assignment)
    return false if assignment.nil?
    return false unless current_user_has_student_privileges?
  end

  def actions_requiring_authorizations?
    []
  end

  def actions_allowed_for_students_and_above
    []
  end

  def actions_restricted_to_tas_and_above
    []
  end
end
