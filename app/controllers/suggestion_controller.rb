class SuggestionController < ApplicationController

  def action_allowed?
    case params[:action]
    when 'create', 'new'
      current_role_name.eql? 'Student'
    else
      ['Instructor',
       'Teaching Assistant',
       'Administrator',
       'Super-Administrator'].include? current_role_name
    end
  end

  def add_comment
    @suggestioncomment = SuggestionComment.new(params[:suggestion_comment])
    @suggestioncomment.suggestion_id=params[:id]
    @suggestioncomment.commenter= session[:user].name
    if  @suggestioncomment.save
      flash[:notice] = "Successfully added your comment"
    else
      flash[:error] = "Error while adding comment"
    end
    redirect_to :action => "show", :id => params[:id]
  end
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list
    @suggestions = Suggestion.where(assignment_id: params[:id])
    @assignment = Assignment.find(params[:id])
  end

  def show
    @suggestion = Suggestion.find(params[:id])
  end

  def new
    @suggestion = Suggestion.new
    session[:assignment_id] = params[:id]
  end

  def create
    @suggestion = Suggestion.new(params[:suggestion])
    @suggestion.assignment_id = session[:assignment_id]
    @suggestion.status = 'Initiated'
    if params[:suggestion_anonymous].nil?
      @suggestion.unityID = session[:user].id
    else
      @suggestion.unityID = "";
    end

    if @suggestion.save
      render :action => 'confirm_save'
    else
      render :action => 'new'
    end
  end

  def confirm_save
    # Action to display successful creation of suggestion
  end

  def submit
    if !params[:add_comment].nil?
      add_comment
    elsif !params[:approve_suggestion].nil?
      approve_suggestion
    elsif !params[:reject_suggestion].nil?
      reject_suggestion
    end
  end

  def approve_suggestion
    @suggestion = Suggestion.find(params[:id])
    @signuptopic = SignUpTopic.new
    @signuptopic.topic_identifier = 'S' + @suggestion.id.to_s
    @signuptopic.topic_name = @suggestion.title
    @signuptopic.assignment_id = @suggestion.assignment_id
    @signuptopic.max_choosers = 3;

    if @signuptopic.save && @suggestion.update_attribute('status', 'Approved')
      flash[:notice] = 'Successfully approved the suggestion.'
    else
      flash[:error] = 'Error when approving the suggestion.'
    end

    #--zhewei--------------------------------------------------------------------------------------------------
    # If you want to create a new team with topic and team members on view, you have to 
    # 1. create new Team
    # 2. create new TeamsUser
    # 3. create new SignedUpTeam
    # 4. create new TeamNode
    # 5. create new TeamUserNode
    #----------------------------------------------------------------------------------------------------------
    #if suggester's signup_preference is yes and his/her team do not has a topic yet, 
    #Expertiza will assign this topic to them automatically and clean its waitlists. 
    user_id = @suggestion.unityID.to_i
    #if this user do not have team in this assignment, create one for him/her
    if SignedUpTeam.team_id(@signuptopic.assignment_id, user_id).nil?
      new_team = AssignmentTeam.create(name: 'Team' + user_id.to_s + '_' + rand(1000).to_s, parent_id: @signuptopic.assignment_id, type: 'AssignmentTeam')
      TeamsUser.create(team_id: new_team.id, user_id: user_id)
      SignedUpTeam.create(topic_id: @signuptopic.id, team_id: new_team.id, is_waitlisted: 0)
      parent = TeamNode.create(:parent_id => @signuptopic.assignment_id, :node_object_id => new_team.id)
      binding.pry
      TeamUserNode.create(:parent_id => parent.id, :node_object_id => user_id)
    else #this user has a team in this assignment, check whether this team has topic or not
      if SignedUpTeam.topic_id(@signuptopic.assignment_id, user_id).nil?
        team_id = SignedUpTeam.team_id(@signuptopic.assignment_id, user_id)
        #clean waitlists
        SignedUpTeam.where(team_id: team_id, is_waitlisted: 1).destroy_all
        SignedUpTeam.create(topic_id: @signuptopic.id, team_id: team_id, is_waitlisted: 0)
      end
    end
    redirect_to :action => 'show', :id => @suggestion
  end

  def reject_suggestion
    @suggestion = Suggestion.find(params[:id])

    if @suggestion.update_attribute('status', 'Rejected')
      flash[:notice] = 'Successfully rejected the suggestion'
    else
      flash[:error] = 'Error when rejecting the suggestion'
      end
    redirect_to :action => 'show', :id => @suggestion
  end
end
