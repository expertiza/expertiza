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
      @late_policy = LatePolicy.new(late_policy_params)
      @late_policy.instructor_id = instructor_id
      begin
        @late_policy.save!
        flash[:notice] = 'The late policy was successfully created.'
        redirect_to action: 'index'
      # If something unexpected happens while saving the record in to database then displays a flash notice and redirect to create a new late policy again.
      rescue StandardError
        flash[:error] = 'The following error occurred while saving the late policy: '
        redirect_to action: 'new'
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
    _valid_penalty, error_message = validate_input(true)
    if error_message
      flash[:error] = error_message
      redirect_to action: 'edit', id: params[:id]
    # If there are no errors, then save the record.
    else
      begin
        penalty_policy.update_attributes(late_policy_params)
        penalty_policy.save!
        LatePolicy.update_calculated_penalty_objects(penalty_policy)
        flash[:notice] = 'The late policy was successfully updated.'
        redirect_to action: 'index'
      # If something unexpected happens while updating, then redirect to the edit page of that policy again.
      rescue StandardError
        flash[:error] = 'The following error occurred while updating the late policy: '
        redirect_to action: 'edit', id: params[:id]
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
    should_check = true
    prefix = is_update ? "Cannot edit the policy. " : ""
    valid_penalty, error_message = true, nil

    if is_update
      existing_late_policy = LatePolicy.find(params[:id])
      if existing_late_policy.policy_name == params[:late_policy][:policy_name]
        should_check = false
      end
    end

    if should_check
      if LatePolicy.check_policy_with_same_name(params[:late_policy][:policy_name], instructor_id)
        error_message = prefix + 'A policy with the same name ' + params[:late_policy][:policy_name] + ' already exists.'
        valid_penalty = false
      end
    end
    return valid_penalty, error_message
  end

  # This function validates the input.
  def validate_input(is_update = false)
    # Validates input for create and update forms
    max_penalty = params[:late_policy][:max_penalty].to_i
    penalty_per_unit = params[:late_policy][:penalty_per_unit].to_i

    valid_penalty, error_message = duplicate_name_check(is_update)
    prefix = is_update ? "Cannot edit the policy. " : ""

    # This check validates the maximum penalty.
    if max_penalty < penalty_per_unit
      error_message = prefix + 'The maximum penalty cannot be less than penalty per unit.'
      valid_penalty = false
    end

    # This check validates the penalty per unit for a late policy.
    if penalty_per_unit < 0
      error_message = 'Penalty per unit cannot be negative.'
      valid_penalty = false
    end

    # This checks maximum penalty does not exceed 100.
    if max_penalty >= 100
      error_message = prefix + 'Maximum penalty cannot be greater than or equal to 100'
      valid_penalty = false
    end

    return valid_penalty, error_message
  end
end
