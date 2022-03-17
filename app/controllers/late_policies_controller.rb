# A controller for interacting with late policies from view classes
# The reason this was added was to perform CRUD operations on late policies.
# See app/views/late_policies.
class LatePoliciesController < ApplicationController

  # This method checks the privileges of current user to perform certain action.
  def action_allowed?
    case params[:action]
    # If the action is creating a new late policy then verifies the current user has the prvilages to perform the action or not.
    when 'new', 'create', 'index'
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    # If the action is to edit/update or destroy a late policy then verifies if the current user has the prvilages to perform the action or not.
    when 'edit', 'update', 'destroy'
      [
        'Super-Administrator',
        'Administrator',
        'Instructor',
        'Teaching Assistant'
      ].include?(current_role_name) &&
      current_user.instructor_id == instructor_id
    end
  end

  # Sets Assigment id.
  def set_assignment_id
    session[:assignment_id] = params[:assignment_id]
  end

  # This method lists all the late policies records from late_policies table in database.
  def index
    @assignment_id = session[:assignment_id]
    @penalty_policies = LatePolicy.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @penalty_policies }
    end
  end

  # GET /late_policies/1
  # GET /late_policies/1.xml
  # This method displays a certain record in late_policies table in the database.
  def show
    @penalty_policy = LatePolicy.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @penalty_policy }
    end
  end

  # GET /late_policies/new
  # GET /late_policies/new.xml
  # New method creates instance of a late policy in the late_policies's table but does not saves in the database.
  def new
    set_assignment_id
    @late_policy = LatePolicy.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @late_policy }
    end
  end

  # GET /late_policies/1/edit
  # This method just fetch a particular record in LatePolicy table.
  def edit
    @penalty_policy = LatePolicy.find(params[:id])
  end

  # POST /late_policies
  # POST /late_policies.xml
  # Create method can create a new late policy.
  # There are few check points before creating a late policy which are written in the if/else statements.
  def create
    # penalty per unit cannot be greater than maximum penalty
    invalid_penalty_per_unit = params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i
    flash[:error] = "The maximum penalty cannot be less than penalty per unit." if invalid_penalty_per_unit
    policy_name_exists = false
    # penalty name should be unique
    if policy_name_exists != LatePolicy.check_policy_with_same_name(params[:late_policy][:policy_name], instructor_id)
      flash[:error] = "A policy with the same name already exists."
      policy_name_exists = true
    end
    # If penalty  is valid and the penalty name does not already exists then tries to update and save.
    if !invalid_penalty_per_unit && !policy_name_exists
      @late_policy = LatePolicy.new(late_policy_params)
      @late_policy.instructor_id = instructor_id
      begin
        @late_policy.save!
        flash[:notice] = "The penalty policy was successfully created."
        redirect_to action: 'index'
      # If something unexpected happens while saving the record in to database then displays a flash notice and redirect to create a new late policy again.
      rescue StandardError => e
        flash[:error] = "The following error occurred while saving the penalty policy: " + e.message
        redirect_to action: 'new'
      end
    # If any of above checks fails, then redirect to create a new late policy again.
    else
      redirect_to action: 'new'
    end
  end

  # PUT /late_policies/1
  # PUT /late_policies/1.xml
  # Update method can update late policy. There are few check points before updating a late policy which are written in the if/else statements.
  def update
    @penalty_policy = LatePolicy.find(params[:id])
    invalid_penalty_per_unit = params[:late_policy][:max_penalty].to_i < params[:late_policy][:penalty_per_unit].to_i
    flash[:error] = "The maximum penalty cannot be less than penalty per unit." if invalid_penalty_per_unit
    policy_name_exists = false
    # if name has changed then need to check if the name already exists or not.
    if params[:late_policy][:policy_name] != @penalty_policy.policy_name
      if policy_name_exists == LatePolicy.check_policy_with_same_name(params[:late_policy][:policy_name], instructor_id)
        flash[:error] = "The policy could not be updated because a policy with the same name already exists."
      end
    end
    # If the the policy passes all the above checks then controller tries to update.
    if !policy_name_exists && !invalid_penalty_per_unit
      begin
        @penalty_policy.update_attributes(late_policy_params)
        @penalty_policy.save!
        LatePolicy.update_calculated_penalty_objects(@penalty_policy)
        flash[:notice] = "The late policy was successfully updated."
        redirect_to action: 'index'
      # If something unexpected happens while updating, then redirect to the edit page of that policy again.
      rescue StandardError
        flash[:error] = "The following error occurred while updating the penalty policy: "
        redirect_to action: 'edit', id: params[:id]
      end
    # If the penalty per unit is invalid then display a flash notice.
    elsif invalid_penalty_per_unit
      flash[:error] = "Cannot edit the policy. The maximum penalty cannot be less than penalty per unit."
      redirect_to action: 'edit', id: params[:id]
    # If same policy name already exists then display a flash notice.
    elsif policy_name_exists
      flash[:error] = "Cannot edit the policy. A policy with the same name " + params[:late_policy][:policy_name] + " already exists."
      redirect_to action: 'edit', id: params[:id]
    end
  end

  # DELETE /late_policies/1
  # DELETE /late_policies/1.xml
  # This method fetches a particular record in the late_policy table and try to destroy's it.
  def destroy
    @penalty_policy = LatePolicy.find(params[:id])
    begin
      @penalty_policy.destroy
    # If the record cannot be deleted then it displays a flash message.
    rescue StandardError
      flash[:error] = "This policy is in use and hence cannot be deleted."
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

  # This function checks if the id exists in parameters and assigns it to the instance variable of penalty policy.
  def late_policy
    @penalty_policy ||= @late_policy || LatePolicy.find(params[:id]) if params[:id]
  end
end
