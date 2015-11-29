# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#
# Use command "whenever --update-crontab --set environment=development" to run cron jobs in development environment
# For production environment use Capistrano recipees
# use "crontab -l" to list all current cron jobs

every 1.day, :at => '6:53 pm' do
  runner "HyperlinkContributor.check_for_updates", :output => 'log/cron.log'
end

