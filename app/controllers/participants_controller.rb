class ParticipantsController < ApplicationController
  autocomplete :user, :name

  def action_allowed?
    case params[:action]
    when 'change_handle'
      current_role_name.eql?("Student")
    else
      ['Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end

  def list
    @root_node = Object.const_get(params[:model]+"Node").find_by_node_object_id(params[:id])
    @parent = Object.const_get(params[:model]).find(params[:id])
    @participants = @parent.participants
    @model = params[:model]
    # E726 Fall2012 Changes Begin
        @special_role = params[:special_role]
        # E726 Fall2012 Changes End
  end

  #OSS_808 change 28th oct
  #required for sending emails
  def email_sent
    DelayedMailer::deliver_mail("recipient.address@example.com")
  end

  def add
    curr_object = Object.const_get(params[:model]).find(params[:id])
    begin
      curr_object.add_participant(params[:user][:name])
      user = User.find_by_name(params[:user][:name])
      @participant = curr_object.participants.find_by_user_id(user.id)
    rescue
      url_new_user = url_for :controller => 'users', :action => 'new'
      flash[:error] = "User #{params[:user][:name]} does not exist. Would you like to <a href = '#{url_new_user}'>create this user?</a>"
    end

    undo_link("User \"#{params[:user][:name]}\" has been added as a participant successfully. ")
    redirect_to :action => 'list', :id => curr_object.id, :model => params[:model]
  end

  def delete
    participant = Participant.find(params[:id])
    name = participant.user.name
    parent_id = participant.parent_id
    begin
      @participant = participant
      participant.delete(params[:force])
      undo_link("User \"#{name}\" has been removed as a participant successfully. ")
    rescue => error
      url_yes = url_for :action => 'delete', :id => params[:id], :force => 1
      url_show = url_for :action => 'delete_display', :id => params[:id], :model => participant.class.to_s.gsub("Participant","")
      url_no  = url_for :action => 'list', :id => parent_id, :model => participant.class.to_s.gsub("Participant","")
      flash[:error] = "A delete action failed: At least one (1) review mapping or team membership exist for this participant. <br/><a href='#{url_yes}'>Delete this participant</a>&nbsp;|&nbsp;<a href='#{url_show}'>Show me the associated items</a>|&nbsp;<a href='#{url_no}'>Do nothing</a><BR/>"
    end
    redirect_to :action => 'list', :id => parent_id, :model => participant.class.to_s.gsub("Participant","")
  end

  def delete_display
    @participant = Participant.find(params[:id])
    @model = params[:model]
  end

  def delete_items
    participant = Participant.find(params[:id])
    maps = params[:ResponseMap]
    teamsusers = params[:TeamsUser]

    if !maps.nil?
      maps.each{
        |rmap_id|
        begin
          ResponseMap.find(rmap_id[0].to_i).delete(true)
        rescue
        end
      }
    end

    if !teamsusers.nil?
      teamsusers.each{
        |tuser_id|
        begin
          TeamsUser.find(tuser_id[0].to_i).delete
        rescue
        end
      }
    end

    redirect_to :action => 'delete', :id => participant.id, :method => :post
  end

  # Copies existing participants from a course down to an assignment
  def inherit
    assignment = Assignment.find(params[:id])
    course = assignment.course
    @copied_participants = []

    if course
      participants = course.participants
      if participants.length > 0
        participants.each{|participant|
          new_participant = participant.copy(params[:id])

          if new_participant
            @copied_participants.push new_participant
          end
        }

        # Only display undo link if copies of participants are created
        if @copied_participants.length > 0
          undo_link("Participants from \"#{course.name}\" has been copied to this assignment successfully. ")
        else
          flash[:note] = 'All course participants are already in this assignment'
        end

      else
        flash[:note] = "No participants were found to inherit."
      end
    else
      flash[:error] = "No course was found for this assignment."
    end


    redirect_to :controller => 'participants', :action => 'list', :id => assignment.id, :model => 'Assignment'
  end

  def bequeath_all
    @copied_participants = []
    assignment = Assignment.find(params[:id])
    if assignment.course
      course = assignment.course
      assignment.participants.each{ |participant|
        new_participant = participant.copy(course.id)

        if new_participant
          @copied_participants.push new_participant
        end
      }
      # only display undo link if copies of participants are created
      if @copied_participants.length > 0
        undo_link("All participants were successfully copied to \"#{course.name}\". " )
      else
        flash[:note] = 'All assignment participants are already part of the course'
      end

      #flash[:note] = "All participants were successfully copied to \""+course.name+"\""
    else
      flash[:error] = "This assignment is not associated with a course."
    end



    redirect_to :controller => 'participants', :action => 'list', :id => assignment.id, :model => 'Assignment'
  end

  # Allow participant to change handle for this assignment
  # If the participant parameters are available, update the participant
  # and redirect to the view_actions page
  def change_handle
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    if params[:participant] != nil
      if AssignmentParticipant.where(parent_id: @participant.parent_id, handle: params[:participant][:handle]).length > 0
        flash[:error] = "<b>#{params[:participant][:handle]}</b> is already in use for this assignment. Please select a different handle."
        redirect_to :controller => 'participants', :action => 'change_handle', :id => @participant
      else
        @participant.update_attributes(params[:participant])
        redirect_to :controller => 'student_task', :action => 'view', :id => @participant
      end
    end
  end

  def delete_assignment_participant
    contributor = AssignmentParticipant.find(params[:id])
    name = contributor.name
    assignment_id = contributor.assignment
    begin
      contributor.destroy
      flash[:note] = "\"#{name}\" is no longer a participant in this assignment."
    rescue
      flash[:error] = "\"#{name}\" was not removed. Please ensure that \"#{name}\" is not a reviewer or metareviewer and try again."
      end
    redirect_to :controller => 'review_mapping', :action => 'list_mappings', :id => assignment_id
  end
end
