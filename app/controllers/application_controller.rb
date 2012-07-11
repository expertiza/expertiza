# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  helper_method :current_user_session, :current_user
  protect_from_forgery unless Rails.env.test?
  filter_parameter_logging :password, :password_confirmation, :clear_password, :clear_password_confirmation

  def authorize 
    unless session[:user]
      flash[:notice] = "Please log in."
      redirect_to(:controller => 'user_sessions', :action => 'new')
    end
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to session[:return_to]
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to session[:return_to]
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  protected
  def list(object_type)
    # Calls the correct listing method based on the role of the
    # logged-in user and the currently selected constraint.
    #
    # Example: object_type = Rubric, constraint = 'list_all'
    # is transformed into Instructor.list_all(object_type, session[:user].id)
    # if the user is currently logged in as an Instructor
    constraint = @display_option.name
    if constraint == nil or constraint == ''
      constraint = 'list_mine'
    end
    
    ApplicationHelper::get_user_role(session[:user]).send(constraint, object_type, session[:user].id)
  end

#begin refactor==================================
   def signup_remove(params,var)
    old_teams_signups = SignedUpUser.find_all_by_creator_id(params[:team_id])
      if !old_teams_signups.nil?
        for old_teams_signup in old_teams_signups
          if old_teams_signup.is_waitlisted == false # i.e., if the old team was occupying a slot, & thus is releasing a slot ...
            first_waitlisted_signup = SignedUpUser.find_by_topic_id_and_is_waitlisted(old_teams_signup.topic_id, true)
            if !first_waitlisted_signup.nil?
              #As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
              first_waitlisted_signup.is_waitlisted = false
              first_waitlisted_signup.save

              #Also update the participant table. But first_waitlisted_signup.creator_id is the team id
              #so find one of the users on the team because the update_topic_id function in participant
              #will take care of updating all the participants on the team
              user_id = TeamsUser.find(:first, :conditions => {:team_id => first_waitlisted_signup.creator_id}).user_id
              if(var)
                begin
                  participant = Participant.find_by_user_id_and_parent_id(user_id,old_team.assignment.id)
                  participant.update_topic_id(old_teams_signup.topic_id)
                  SignUpTopic.cancel_all_waitlists(first_waitlisted_signup.creator_id, SignUpTopic.find(old_teams_signup.topic_id)['assignment_id'])
                end
              else
                participant = Participant.find_by_user_id(user_id)
                participant.update_topic_id(nil)
              end

            end # if !first_waitlisted_signup.nil
            # Remove the now-empty team from the slot it is occupying.
          end # if old_teams_signup.is_waitlisted == false
          old_teams_signup.destroy
        end
      end
   end
#end refactor===================================================

  def get(object_type, id)
    # Returns the first record found.  The record may not be found (e.g.,
    # because it is private and belongs to someone else), so catch the exceptions.
    ApplicationHelper::get_user_role(session[:user]).get(object_type, id, session[:user].id)
  end
  
  def set_up_display_options(object_type)
    # Create a set that will be used to populate the dropbox when a user lists a set of objects (assgts., questionnaires, etc.)
    # Get the Instructor::questionnaire constant
    @display_options = eval ApplicationHelper::get_user_role(session[:user]).class.to_s+"::"+object_type 
    @display_option = DisplayOption.new
    @display_option.name = 'list_mine'
    @display_option.name = params[:display_option][:name] if params[:display_option]
  end
  
  # Use this method to validate the current user in order to avoid allowing users
  # to see unauthorized data.
  # Ex: return unless current_user_id?(params[:user_id])
  def current_user_id?(user_id)
    if user_id != session[:user].id
      redirect_to '/denied'
      return false
    else
      return true
    end
  end

end
