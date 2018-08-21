# added the badges controller as part of E1822
# added a create method for badge creation functionality
class BadgesController < ApplicationController
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator'].include? current_role_name
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
    @badge.image_url = params[:badge][:image_url]
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

  # def list
  #   @instructor_id = params[:id]
  #   @badges = Badge.where(instructor_id: @instructor_id)
  #               .or(Badge.where(private: 0)).to_a
  #   @badges.sort_by{|b| b.instructor_id == @instructor_id}
  # end

  def upload_evidence
    participant = Participant.find_by_id(params[:id])
    @assignment_badges = AwardedBadge.where(pariticpant_id: pariticpant.id, approval_status: 0)
    #Can make the assumption that this is an assigment participant because assignment badge
    @submissions = pariticpant.team.submissions
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :image_name)
  end
end
