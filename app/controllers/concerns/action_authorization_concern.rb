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

  # Determines if the current action is authorized for the given assignment
  def action_authorized?(assignment_id)
    allowed_actions_for_roles.include?(action_name) &&
      are_needed_authorizations_present?(assignment_id, required_authorizations_for_actions)
  end

  # List of actions allowed for specific roles
  def allowed_actions_for_authorizations
    %w[list]
  end

  # Authorizations required for specific actions
  def required_authorizations_for_actions
    raise NotImplementedError, 'You must implement `required_authorizations_for_action` in the including controller'
  end
end
