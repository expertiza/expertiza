class JoinTeamRequest < ActiveRecord::Base
  belongs_to :team
  has_one :participant

  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, _model) { controller && controller.current_user }
end
