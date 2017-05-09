class ActivitiesController < ApplicationController
  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_user.role.name
  end

  def index
    user = params[:user]
    activity_time = params[:activity_time] ? params[:activity_time][0] : nil
    @activities = PublicActivity::Activity.order("created_at desc")
    unless user.to_s.strip.empty?
      users = User.where("name like ?", "%#{params[:user]}%")
      @activities = @activities.where(owner_id: users)
    end
    @activities = @activities.where("Date(created_at) = ?", activity_time) unless activity_time.to_s.strip.empty?
  end

  def search_by_time; end
end
