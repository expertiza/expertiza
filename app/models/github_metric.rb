class GithubMetric < ActiveRecord::Base
  enum graph_types: ['number of commits','lines added','lines deleted']
  enum timeline_types: ['week', 'student']
end