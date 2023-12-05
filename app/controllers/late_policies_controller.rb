# A controller for interacting with late policies from view classes.
# The reason this was added was to perform CRUD operations on late policies.
# See app/views/late_policies.
class LatePoliciesController < ApplicationController
  include AuthorizationHelper

  # This method checks the privileges of the current user to perform a certain action.
  def action_allowed?
    case params[:action]
    # If the action is creating a new late policy then verifies the current user has the prvilages to perform the action or not.
    when 'new', 'create', 'index'
      current_user_has_ta_privileges?
    # If the action is to edit/update or destroy a late policy then verifies if the current user has the prvilages to perform the action or not.
    when 'edit', 'update', 'destroy'
      current_user_has_ta_privileges? &&
        current_user.instructor_id == instructor_id
    end
  end

  # This method lists all the late policies records from late_policies table in database.
  def index
    @penalty_policies = LatePolicy.where(['instructor_id = ? OR private = 0', instructor_id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @penalty_policies }
    end
  end

  # This method displays a certain record in late_policies table in the database.
  def show
    @penalty_policy = LatePolicy.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @penalty_policy }
    end
  end

  # New method creates instance of a late policy in the late_policies's table but does not saves in the database.
  def new
    @penalty_policy = LatePolicy.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @penalty_policy }
    end
  end

  # This method just fetch a particular record in LatePolicy table.
  def edit
    @penalty_policy = LatePolicy.find(params[:id])
  end

  # Create method can create a new late policy.
  # There are few check points before creating a late policy which are written in the if/else statements.
  def create
    # First this function validates the input then save if the input is valid.
    valid_penalty, error_message = validate_input
    if error_message
      flash[:error] = error_message
    end

    # If penalty  is valid then tries to update and save.
    if valid_penalty
      create_new_late_policy(late_policy_params)
      error_thrown = save_late_policy
      if error_thrown
        # If there was an error thrown go to new, otherwise go to index
        redirect_to action: 'new'
      else
        redirect_to action: 'index'
      end
    # If any of above checks fails, then redirect to create a new late policy again.
    else
      redirect_to action: 'new'
    end
  end

  # Update method can update late policy. There are few check points before updating a late policy which are written in the if/else statements.
  def update
    penalty_policy = LatePolicy.find(params[:id])

    # First this function validates the input then save if the input is valid.
    valid_penalty, error_message = validate_input(true)
    if !valid_penalty
      flash[:error] = error_message
      redirect_to action: 'edit', id: params[:id]
    # If there are no errors, then save the record.
    else
      penalty_policy.update_attributes(late_policy_params)
      error_thrown = save_late_policy(true)
      # If there was an error thrown, go back to edit, otherwise go to index
      if error_thrown
        redirect_to action: 'edit', id: params[:id]
      else
        redirect_to action: 'index'
      end
    end
  end

  # This method fetches a particular record in the late_policy table and try to destroy's it.
  def destroy
    @penalty_policy = LatePolicy.find(params[:id])
    begin
      @penalty_policy.destroy
    rescue StandardError
      flash[:error] = 'This policy is in use and hence cannot be deleted.'
    end
    redirect_to controller: 'late_policies', action: 'index'
  end

  private

  # This function ensures that a specific parameter is present.If not then throws and error.
  def late_policy_params
    params.require(:late_policy).permit(:policy_name, :penalty_per_unit, :penalty_unit, :max_penalty)
  end

  # This function check's if the current user is instructor or not.If not then throws and error.
  def instructor_id
    late_policy.try(:instructor_id) ||
      current_user.instructor_id
  end

  def late_policy
    # This function checks if the id exists in parameters and assigns it to the instance variable of penalty policy.
    @penalty_policy ||= @late_policy || LatePolicy.find(params[:id]) if params[:id]
  end

  # This function checks if the policy name already exists or not and returns boolean value for penalty and the error message.
  def duplicate_name_check(is_update = false)
    valid_penalty, error_message = true, nil
    prefix = is_update ? "Cannot edit the policy. " : ""
  
    if should_check_policy_name?(is_update)
      valid_penalty, error_message = check_for_duplicate_name(prefix)
    end
  
    return valid_penalty, error_message
  end

  # This is a helper function for the duplicate name check
  def should_check_policy_name?(is_update)
    # If the function is called in the context of updating a policy
    if is_update
        # Find the existing late policy by its ID
        existing_late_policy = LatePolicy.find(params[:id])
        # Check if the policy name in the request is different from the existing policy's name
        # Return true if they are different, indicating a need to check the policy name
        return existing_late_policy.policy_name != params[:late_policy][:policy_name]
    end
    # If not an update, always return true to indicate that the policy name should be checked
    return true
  end

  # This is a helper function for the duplicate name check
  def check_for_duplicate_name(prefix)
    # Using `exists?` to check if a LatePolicy with the same name already exists for the instructor.
    # It's assumed that `params[:late_policy][:policy_name]` holds the name of the policy and 
    # `instructor_id` is the ID of the instructor.
    if LatePolicy.exists?(policy_name: params[:late_policy][:policy_name], instructor_id: instructor_id)
        # Construct an error message indicating the duplicate name, if the policy already exists
        error_message = "#{prefix}A policy with the same name '#{params[:late_policy][:policy_name]}' already exists."
        valid_penalty = false
    else
        # If no duplicate name is found, set valid_penalty to true
        valid_penalty = true
        error_message = nil
    end

    # Return the validity status of the penalty and the corresponding error message, if any
    return valid_penalty, error_message
  end

  # This function validates the input.
  def validate_input(is_update = false)
    # Validates input for create and update forms
    max_penalty = params[:late_policy][:max_penalty].to_i
    penalty_per_unit = params[:late_policy][:penalty_per_unit].to_i
    error_messages = []

    # Validates the name is not a duplicate
    valid_penalty, name_error = duplicate_name_check(is_update)
    error_messages << name_error if name_error

    # This validates the max_penalty to make sure it's within the correct range
    if max_penalty_validation(max_penalty, penalty_per_unit)
      error_messages << "#{error_prefix(is_update)}The maximum penalty must be between the penalty per unit and 100."
      valid_penalty = false
    end

    # This validates the penalty_per_unit and makes sure it's not negative
    if penalty_per_unit_validation(penalty_per_unit)
      error_messages << 'Penalty per unit cannot be negative.'
      valid_penalty = false
    end

    [valid_penalty, error_messages.join("\n")]
  end

  # Validate the maximum penalty and ensure it's in the correct range
  def max_penalty_validation(max_penalty, penalty_per_unit)
    max_penalty < penalty_per_unit || max_penalty > 100
  end

  # Validates the penalty per unit
  def penalty_per_unit_validation(penalty_per_unit)
    penalty_per_unit < 0
  end

  # Validation error prefix
  def error_prefix(is_update)
    is_update ? "Cannot edit the policy. " : ""
  end

  # Create and save the late policy with the required params
  def create_new_late_policy(params)
    @late_policy = LatePolicy.new(params)
    @late_policy.instructor_id = instructor_id
  end

  # Saves the late policy called from create or update
  def save_late_policy(from_update=false)
    error_thrown = false
    begin
      @late_policy.save!
      if from_update
        # If the method that called this is update
        LatePolicy.update_calculated_penalty_objects(penalty_policy)
      end
      # The code at the end of the string gets the name of the last method (create, update) and adds a d (created, updated)
      flash[:notice] = "The late policy was successfully created." if !from_update
      flash[:notice] = "The late policy was successfully updated." if from_update
    rescue StandardError
      error_thrown = true
      # If something unexpected happens while saving the record in to database then displays a flash notice and redirect to create a new late policy again.
      if from_update
        message_thrown = 'The following error occurred while updating the late policy: '
      else
        message_thrown = 'The following error occurred while saving the late policy: '
      end
      flash[:error] = message_thrown
    end
    error_thrown
  end
end
