class InteractionController < ApplicationController
  def instructor_view

    @teams=Team.find_all_by_parent_id(params[:id])
    puts "teams"+@teams.length.to_s
    @interactions=Array.new
    @participant_helped=Array.new
    @team_helped=Array.new
    for team in @teams
      @participant_helped += HelperInteraction.find_all_by_team_id(team.id)
    @team_helped += HelpeeInteraction.find_all_by_team_id(team.id)

    end
    puts "helper"
      puts @participant_helped
      puts "helpee"
      puts @team_helped
     render  'instructor_view', :id=>params[:id],:locals => {:id=>params[:id],:expanded => (params[:expanded])}
  end

  def view
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @participant_helps = HelperInteraction.find_interactions(params[:id])
    @participant_helped = HelpeeInteraction.find_interactions(params[:id])

  end

  def new


  end

  def interaction_view
    if params[:type]=='Show'
    puts params[:id]
    @interaction = Interaction.find(params[:id])
    @helper_record = HelperInteraction.first(:conditions => ["participant_id = ? AND team_id = ?", @interaction.participant_id,@interaction.team_id ])
    puts !@helper_record


    @helpee_record = HelpeeInteraction.first(:conditions => ["participant_id = ? AND team_id = ?",@interaction.participant_id,@interaction.team_id ])
   puts !@helpee_record


    render :partial=>  'instructor_view', :locals => {:interaction=>@interaction ,:id=>params[:id],:expanded => (params[:expanded])}
    else
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

end