class ActivitiesController < ApplicationController
  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_user.role.name
  end
  def index
    @activities = PublicActivity::Activity.order("created_at desc")
  end
end
