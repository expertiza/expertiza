class AssignmentSignupsController < ApplicationController
  def index
    list
    render action: 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: [:destroy, :create, :update],
         redirect_to: {action: :list}

  def list
    @assignment_signups = SignUpSheet.all
  end

  def listuser
    @user_id = session[:user].id
    if session[:user].role_id == 1
      @signups = SignUpSheet.find_by_sql("select * from signup_sheets where assignment_id in (select assignment_id from participants where user_id = " + session[:user].id.to_s + ")")
    else
      @signups = SignUpSheet.find_by_sql("select * from signup_sheets")
    end
  end

  def show
    @assignment_signup = AssignmentSignup.find(params[:id])
  end

  def new
    @assignment_signup = AssignmentSignup.new
    @signup_sheets = SignUpSheet.all
    @assignments = Assignment.find_by_sql("select * from assignments where id not in (select assignment_id from assignment_signups where signup_id = " + @params[:id].to_s + ")")
  end

  def create
    @assignment_signup = AssignmentSignup.new(params[:assignment_signup])
    @assignment_signup.assignment_id = params[:assignment_id]
    @assignment_signup.signup_id = params[:signup_id]

    if @assignment_signup.save
      @assignments = Assignment.find(params[:assignment_id])
     #E1703 Change
      @@event_logger.warn "&Assignment Signup|Create|#{session[:user].role_id}|#{session[:user].id}|Signup for Assignment|Assignment : #{@assignments.name}} "
     #E1703 Change
      flash[:notice] = 'The assignment sign-up was successfully created for assignment ' + @assignments.name
      redirect_to controller: 'signup_sheets', action: 'list'
    else
      @signup_sheets = SignUpSheet.all
      @assignments = Assignment.all
      render action: 'new'
    end
  end

  def edit
    @assignments = Assignment.all
    @assignment_signup = AssignmentSignup.find(params[:id])
  end

  def update
    @assignment_signup = AssignmentSignup.find(params[:id])
    @assignment_signup.assignment_id = params[:assignment_id]
    if @assignment_signup.update_attributes(params[:assignment_signup])
      flash[:notice] = 'The assignment sign-up was successfully updated.'
      #E1703 Change
      @@event_logger.warn "&Assignment Signup|Create|#{session[:user].role_id}|#{session[:user].id}|Signup for Assignment|Assignment : #{@assignment_signup.name} "
      #E1703 Change
      redirect_to action: 'show', id: @assignment_signup
    else
      @assignments = Assignment.all
      render action: 'edit'
    end
  end

  def destroy
    #E1703 Change
    @@event_logger.warn "&Assignment Signup|Delete|#{session[:user].role_id}|#{session[:user].id}|Delete Signup for Assignment|Assignment : #{AssignmentSignup.find(params[:id]).name}} "
    #E1703 Change

    AssignmentSignup.find(params[:id]).destroy

    redirect_to action: 'list'
  end
end
