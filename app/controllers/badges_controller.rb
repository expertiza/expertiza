class BadgesController < ApplicationController
  def action_allowed?
    true
  end

  def new
    @badge = Badge.new
    session[:return_to] ||= request.referer
  end

  def redirect_to_assignment
    redirect_to session.delete(:return_to)
  end

  def create
    @badge = Badge.new(badge_params)
    respond_to do |format|
      if @badge.save
        format.html { redirect_to session.delete(:return_to), notice: 'Badge was successfully created' }
        #format.json { render :show, status: :created, location: @badge }
      else
        format.html { render :new }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :image_name)
  end
end
