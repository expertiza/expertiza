class GithubContributor < ActiveRecord::Base
  attr_accessible :user_name, :github_id,
                  :total_commits, :files_changed,
                  :lines_changed, :lines_added,
                  :lines_removed, :lines_persisted,
                  :submission_records_id, :week_timestamp
end
