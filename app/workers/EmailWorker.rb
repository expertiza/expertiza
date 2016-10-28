class EmailWorker
  include Sidekiq::Worker
  def email_user(user_id)

  end

  def email_team(team_id)

  end
end
