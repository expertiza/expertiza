#Signup controller has all the functions related to signup for a topic and droppng a selected
#topic. These are all actions that a user performs. The following is a brief explanation 
#of what each method does.

class SignupController < ApplicationController
  # The manage team helper is used to update the create new teams, update teams, 
  # delete teams etc. For more information refer /app/helpers/ManageTeamHelper
  include ManageTeamHelper


  #Displays all the topics available for an assignment, including number of people 
  #who can choose the topic, number of people who have already chosen the topic, etc.
  def list
    @assignment_id = params[:id]
    @sign_up_topics = SignUpTopic.where( ['assignment_id = ?', params[:id]])
    @slots_filled =  SignUpTopic.find_slots_filled(params[:id])
    @slots_waitlisted = SignUpTopic.find_slots_waitlisted(params[:id])
    @show_actions = true

    #Find whether assignment is team assignment.
    assignment = Assignment.find(params[:id])

    if !assignment.staggered_deadline? and assignment.due_dates.find_by_deadline_type_id(DeadlineType.find_by_name("submission").id).due_at < Time.now
      @show_actions = false
    end

    #Find whether the user has signed up for any topics; if so the user won't be able to
    #sign up again unless the former was a waitlisted topic
    #if team assignment, then team id needs to be passed as parameter else the user's id
    users_team = SignedUpUser.find_team_users(params[:id],(session[:user].id))

    if users_team.size == 0
      @selected_topics = nil
    else
      #TODO: fix this; cant use 0
      @selected_topics = other_confirmed_topic_for_user(params[:id], users_team[0].t_id)
    end
  end


  #This function lets the user choose a particular topic. This function is invoked when 
  #the user clicks the green check mark in the signup sheet
  def signup
    #Find the assignment to which user is signing up.
    @assignment = Assignment.find(params[:assignment_id])

    #Everything is a team assignment.  Everyone gets a team.
    #Check whether the user already has a team for this assignment.
    #There are likely paths that will allow the user to get to here without
    #having an assigned team.
    @users_team = SignedUpUser.find_team_users(params[:assignment_id],(session[:user].id))

    if @users_team.size == 0
      #If team is not yet created, create new team.
      @team = AssignmentTeam.create_team_and_node(params[:assignment_id])
      @user = User.find(session[:user].id)
      @teamuser = create_team_users(user, team.id)
      @confirmationStatus = confirm_topic(team.id, params[:id], params[:assignment_id])
    else
      @confirmationStatus = confirm_topic(users_team[0].t_id, params[:id], params[:assignment_id])
    end

    redirect_to :action => 'list', :id => params[:assignment_id]
  end


  # Checks for other topics a user may have already signed up for. 
  # These include both confirmed as well as waitlisted topics.
  def other_confirmed_topic_for_user(assignment_id, creator_id)
    user_signup = SignedUpUser.find_user_signup_topics(assignment_id,creator_id)
    user_signup
  end


  def confirm_topic(creator_id, topic_id, assignment_id)
    # Check whether user has signed up already.
    user_signup = other_confirmed_topic_for_user(assignment_id, creator_id)

    sign_up = SignedUpUser.new
    sign_up.topic_id = params[:id]
    # NOTE: Creator is always a team.
    sign_up.creator_id = creator_id

    # Initialize the return value.
    result = false

    if user_signup > 0
      # Check that all the topics chosen by the user are waitlisted
      # otherwise don't let them choose another topic.
      for user_signup_topic in user_signup
        if user_signup_topic.is_waitlisted == false
          flash[:error] = "You have already signed up for a topic."
          return false
        end
      end
    end

    # Using a DB transaction to ensure atomic inserts
    ActiveRecord::Base.transaction do
      # NOTE: This is likely not checking if the user is on a team that
      #       already has this topic assigned to it.
      sign_up.sign_up_for_topic(session[:user].id, topic_id)
      result = sign_up.save
    end

    result
  end


  #This function is used to drop a previously selected topic. This function is invoked when the user clicks the red
  #cancel mark.
  def delete_signup
    delete_signup_for_topic(params[:assignment_id],params[:id])
    redirect_to :action => 'list', :id => params[:assignment_id]
  end


  # Used by delete_signup function above. This functions updates all the database tables 
  # when the user drops the topic.
  def delete_signup_for_topic(assignment_id,topic_id)
    # Find whether assignment is team assignment
    # All assignments are team assignments now.
    assignment = Assignment.find(assignment_id)

    # Making sure that the drop date deadline hasn't passed
    dropDate = DueDate.where( {:assignment_id => assignment.id, :deadline_type_id => '6'}).first

    if(!dropDate.nil? && dropDate.due_at < Time.now)
      flash[:error] = "You cannot drop this topic because the drop deadline has passed."
    else
      # If team assignment find the creator id from teamusers table and teams.
      # Users_team will contain the team id of the team to which the user belongs.
      users_team = SignedUpUser.find_team_users(assignment_id,(session[:user].id))
      signup_record = SignedUpUser.where(topic_id: topic_id, creator_id:  users_team[0].t_id).first

      # TODO: This should be a model function.  Taking someone off a wait list and push them into a topic.
      # TODO: Move this to signed_up_user.  Consider changing the model name to signed_up_team.
      # If a confirmed slot is deleted then push the first waiting list member
      # to confirmed slot if someone is on the waitlist.
      if signup_record.is_waitlisted == false
        # Find the first wait listed user if exists
        first_waitlisted_user = SignedUpUser.where(topic_id: topic_id, is_waitlisted:  true).first

        if !first_waitlisted_user.nil?
          # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
          ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
          first_waitlisted_user.is_waitlisted = false
          first_waitlisted_user.save

          #update the participants details
          user_id = TeamsUser.where( {:team_id => first_waitlisted_user.creator_id}).first.user_id
          participant = Participant.where(user_id: user_id, parent_id: assignment.id).first
          participant.update_topic_id(topic_id)

          Waitlist.cancel_all_waitlists(first_waitlisted_user.creator_id,assignment_id)
        end
      end

      if !signup_record.nil?
        participant = Participant.where(user_id: session[:user].id, parent_id:  assignment_id).first
        #update participant's topic id to nil
        participant.update_topic_id(nil)
        signup_record.destroy
      end
    end #end condition for 'drop deadline' check
  end
end
