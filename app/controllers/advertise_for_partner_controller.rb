class AdvertiseForPartnerController < ApplicationController
  def new
    puts "team #{params[:team_id]}"
    Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
  end

  def remove
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])
    redirect_to :controller => 'student_team', :action => 'view' , :id => params[:team_id]
  end

  def add_advertise_comment
    Team.update(params[:id],:comments_for_advertisement => params[:comment].to_s)
    #Team.update_all("comments_for_advertisement=comments",:id=>params[:id])
    redirect_to :controller => 'student_team', :action => 'view' , :id => params[:id]
  end

  def update
    @team=Team.find(params[:id])
    @team.comments_for_advertisement = params[:team][:comments_for_advertisement]
    puts 'yay!!!!'+params[:team][:comments_for_advertisement].to_json
    if @team.save
      flash[:notice]='Advertisement edited successfully!'
      redirect_to :controller => 'student_team', :action => 'view' , :id => params[:id]
    else
      flash[:notice]='Advertisement edited successfully!'
      redirect_to :controller => 'student_team', :action => 'edit' , :id => @team.id
    end
  end

  def edit
    @team = Team.find(params[:team_id])
  end
end