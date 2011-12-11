class InteractionController < ApplicationController

  # module for instructor to view all interactions
  def instructor_view

    @teams=Team.find_all_by_parent_id(params[:id])    # get all teams in curent assignment

    p params[:id]
    p @teams
    @interactions=Array.new
    @participant_helped=Array.new
    @team_helped=Array.new

    #get all interactions of all teams

    for team in @teams

      @participant_helped += HelperInteraction.find_all_by_team_id(team.id)
      @team_helped += HelpeeInteraction.find_all_by_team_id(team.id)
    end
    p @participant_helped
    p @team_helped
    render  'instructor_view', :id=>params[:id],:locals => {:id=>params[:id],:expanded => (params[:expanded])}

  end

  def view

    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @participant_helps = HelperInteraction.find_interactions(params[:id])
    @participant_helped = HelpeeInteraction.find_interactions(params[:id])
    @assignment=params[:assignment]
  end

  def create
    @curr_participant=session[:participant_id]
    p "part id"
    p session[:participant_id]
    if(params[:type]=="helpee")
      @user = User.find_by_name(params[:helper])
      if !@user
        flash[:notice] = "\"#{params[:helper].strip}\" does not exist."
        redirect_to :controller=>'interaction', :action=>'new', :assignment_id=>params[:assign], :type=>params[:type]

      else
        @helper_user=@user.id
        @helper_assignment= params[:assign]
        @helper_participant=Participant.first(:conditions => ['parent_id = ? and user_id = ?',params[:assign],@helper_user])

        @selected_team=Team.first(:conditions => ['parent_id=? and name=?',@helper_assignment,params[:teams]])
        @helpee_record1 = HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @helper_participant,@selected_team.id])

        if !@helpee_record1
          @interaction = HelpeeInteraction.new(params[:interactions])
          @interaction.interaction_datetime=params[:interaction_date]
          @interaction.team_id=@selected_team.id
          @interaction.score=params[:score]
          @interaction.participant_id=@helper_participant.id
          @interaction.status='Not Confirmed'

          if @interaction.save
            @helper_record2 = HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
            if @helper_record2
              @helpee_record2=HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
              @helpee_record2.update_attribute('status','Confirmed')
              @helper_record2.update_attribute('status','Confirmed')
            end

          else
            redirect_to :action => 'new' , :assignment_id=>params[:assign], :type=>params[:type]
          end
        else
          flash[:notice] =" Interaction already reported."
          redirect_to :controller=>'interaction', :action=>'view', :id=>session[:participant_id]
        end
      end
    elsif (params[:type]=="helper")

      @selected_team=Team.first(:conditions => ['parent_id=? and name=?',params[:assign],params[:teams]])
      @helper_record1 = HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",session[:participant_id],@selected_team.id ])

      if !@helper_record1

        @interaction = HelperInteraction.new(params[:interactions])
        @interaction.participant_id=session[:participant_id]
        @interaction.interaction_datetime=params[:interaction_date]
        @interaction.team_id=@selected_team.id
        @interaction.status='Not Confirmed'
        @interaction.save

        @helpee_record2 = HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",@interaction.participant_id,@interaction.team_id ])
        if @helpee_record2
          @helpee_record2.update_attribute('status','Confirmed')
          @helper_record2=HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",@interaction.participant_id,@interaction.team_id ])
          @helper_record2.update_attribute('status','Confirmed')
        end
      else
        flash[:notice] =" Interaction already reported."
        redirect_to :controller=>'interaction', :action=>'view', :id=>session[:participant_id]
      end
      #  @interaction = Interaction.find(participant_id)
      #  @helper_record = HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
      #  @helpee_record = HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",@interaction.participant_id,@interaction.team_id ])
      #  if @helper_record
      #    @helpee_record.update_attribute('status','Confirmed')
      #  end

      #  if @helpee_record
      #    @helper_record.update_attribute('status','Confirmed')
      #  end
    end
  end


  def new


    @assignment=params[:assignment_id]
    if(params[:type]=='helper')
      @interaction=HelperInteraction.new
      session[:participant_id] = params[:id]

    elsif(params[:type]=='helpee')
      @interaction=HelpeeInteraction.new
      session[:participant_id] = params[:id]

    end
    @type = params[:type]
    @id=params[:id]

    #@min = 1
    #@max = 5
    @advices = InteractionAdvice.find_all_by_assignment_id(params[:assignment_id])
    @advices = @advices.sort{|x,y|x.score<=>y.score}
    p params[:assignment_id]
    p @advices

    #@question_advices[0] = "It was not helpful and waste of time"
    #@question_advices[1] = "Time spent was not that much worth"
    #@question_advices[2] = "It helped us but did not solve all the problems"
    #@question_advices[3] = "Some of the discussions helped to solve bottlenecks in our project"
    #@question_advices[4] = "It was really helpful and helped to solve our doubts "



  end

  #module to show interaction details and approve interaction by instructor

  def interaction_view

    if params[:type]=='Show'    #  if shw interaction details
      @interaction = Interaction.find(params[:id])
      @helper_record = HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
      @helpee_record = HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",@interaction.participant_id,@interaction.team_id ])
      render :partial=>  'instructor_view', :locals => {:interaction=>@interaction ,:id=>params[:id],:expanded => (params[:expanded])}

    else                      # if approve interaction
      @interaction = Interaction.find(params[:id])
      @interaction.update_attribute("status","Approved")
      helper=HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
      helper.update_attribute("status","Approved")
      render :partial=>  'instructor_view', :locals => {:interaction=>@interaction ,:id=>params[:id],:expanded => (params[:expanded])}
    end

  end

  def expand_details
    interaction = Interaction.find(params[:interaction])
    @helper_record = HelperInteraction.find(interaction.helper_entry)

    if !@helper_record
      @helper_record = HelperInteraction.new
    end

    @helpee_record = HelpeeInteraction.find(interaction.helpee_entry)
    if !@helpee_record
      @helpee_record = HelpeeInteraction.new
    end

    render :partial => 'interaction', :locals => {:interaction => @interaction , :type=>params[:type] , :expanded => (params[:expanded])}
  end


  def edit_advice
    @advices = InteractionAdvice.find_all_by_assignment_id(params[:id])
    @id = params[:id]



  end

  def update_advice

    flash[:notice] = InteractionAdvice.update_advice(params[:advices],params[:assign])

    if !flash[:notice].nil?
      redirect_to :controller => :interaction , :action => :edit_advice ,:id => params[:assign]
    else
      flash[:notice] = "Advice added sucessfully"
      redirect_to :controller => :assignment , :action => :edit ,:id => params[:assign]
    end
  end



end