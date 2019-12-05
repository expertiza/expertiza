class GithubMetric < ActiveRecord::Base
  enum graph_types: ['Commit Metrics','Lines Added Metrics','Lines Deleted Metrics']
  enum timeline_types: ['By Week', 'By Student']
end
