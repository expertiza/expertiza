require 'sidekiq'

class Worker
  include Sidekiq::Worker
  # ActionMailer in Rail 4 submits jobs in jobs queue instead of default queue. Rails 5 and onwards
  # ActionMailer will submit mailer jobs to default queue. We need to remove the line below in that case!
  sidekiq_options queue: 'jobs'

  # we override this method in the following classes and implement it there
  def perform(*args)
    raise "This method must be overriden."
  end
end