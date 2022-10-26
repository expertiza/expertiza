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
    @late_policies = LatePolicy.where(['instructor_id = ? OR private = 0', instructor_id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @late_policies }
    end
  end

  # This method displays a certain record in late_policies table in the database.
  def show
    @late_policy = LatePolicy.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @late_policy }
    end
  end

  # New method creates instance of a late policy in the late_policies's table but does not saves in the database.
  def new
    @late_policy = LatePolicy.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @late_policy }
    end
  end

  # This method just fetch a particular record in LatePolicy table.
  def edit
    @late_policy = LatePolicy.find(params[:id])
  end

  # Create method can create a new late policy.
  # There are few check points before creating a late policy which are written in the if/else statements.
  def create
    # this function validates the policy name
    valid_name_penalty, error_message = check_if_policy_name_exists('')

    # First this function validates the input then save if the input is valid.
    valid_attr_penalty, error_message = validate_input('', error_message)

    valid_penalty = valid_name_penalty && valid_attr_penalty

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
    late_policy = LatePolicy.find(params[:id])

    # this function checks if the policy name was update and then validates the policy name
    prefix = 'Cannot edit the policy. '
    if late_policy.policy_name != late_policy_params[:policy_name]
      valid_name_penalty, error_message = check_if_policy_name_exists(prefix)
    end

    # First this function validates the input then save if the input is valid.
    valid_attr_penalty, error_message = validate_input(prefix, error_message)

    if error_message
      flash[:error] = error_message
      redirect_to action: 'edit', id: params[:id]
    # If there are no errors, then save the record.
    else
      begin
        late_policy.update_attributes(late_policy_params)
        late_policy.save!
        LatePolicy.update_calculated_penalty_objects(late_policy)
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
    @late_policy = LatePolicy.find(params[:id])
    begin
      @late_policy.destroy
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
    @late_policy ||= LatePolicy.find(params[:id]) if params[:id]
  end

  # This function checks if the policy name already exists or not and returns the error message.
  def check_if_policy_name_exists(prefix)
    error_message = nil
    if LatePolicy.check_policy_with_same_name(late_policy_params[:policy_name], instructor_id)
      error_message = prefix + 'A policy with the same name ' + late_policy_params[:policy_name] + ' already exists.'
      return false, error_message
    end
    return true, error_message
  end

  # This function validates the input and returns boolean for valid penalty abd error meassage.
  def validate_input(prefix, error_message)
    # Validates input for create and update forms
    max_penalty = late_policy_params[:max_penalty].to_i
    penalty_per_unit = late_policy_params[:penalty_per_unit].to_i
    valid_penalty = false

    # This check validates the maximum penalty.
    if max_penalty < penalty_per_unit
      error_message = "#{error_message.nil? ? "" : error_message + " "}" + prefix + 'The maximum penalty cannot be less than penalty per unit.'
    end

    # This check validates the penalty per unit for a late policy.
    if penalty_per_unit < 0
      error_message = "#{error_message.nil? ? "" : error_message + " "}" + "Penalty per unit cannot be negative."
    end

    # This checks maximum penalty does not exceed 100.
    if max_penalty >= 100
      error_message = "#{error_message.nil? ? "" : error_message + " "}" + prefix + 'Maximum penalty cannot be greater than or equal to 100.'
    end

    # This checks if any error message was generated.
    if error_message.nil?
      valid_penalty = true
    end

    return valid_penalty, error_message
  end
end
