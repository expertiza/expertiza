class PagesController < ApplicationController
  def setup
    render 'site_admin'
  end
  alias_method :admin, :setup

  def leaderboard
    redirect_to controller: :leaderboard, action: :index
  end
end
