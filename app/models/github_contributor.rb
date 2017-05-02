class GithubContributor < ActiveRecord::Base
  attr_accessible
  belongs_to :submission_record
end
