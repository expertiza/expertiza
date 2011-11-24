class AdvertiseForPartnerController < ApplicationController
  def new
    puts "team #{params[:team_id]}"
    Team.update_all("advertise_for_partner=true",:id=>params[:team_id])
  end

  def remove
    Team.update_all("advertise_for_partner=false",:id=>params[:team_id])
    redirect_to :controller => 'student_team', :action => 'view' , :id => params[:team_id]
  end

  def edit
    #TODO: edit the comments for advertisement for partners||||
  end
end