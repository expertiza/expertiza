# added the badges controller as part of E1822
# added a create method for badge creation functionality
class BadgesController < ApplicationController
  include AuthorizationHelper

  def action_allowed?
    current_user_has_ta_privileges?
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
    image_file = params[:badge][:image_file]
    if image_file
      File.open(Rails.root.join('app', 'assets', 'images', 'badges', image_file.original_filename), 'wb') do |file|
        file.write(image_file.read)
      end
      @badge.image_name = image_file.original_filename
    else
      @badge.image_name = ''
    end

    respond_to do |format|
      if @badge.save
        format.html { redirect_to session.delete(:return_to), notice: 'Badge was successfully created' }
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
