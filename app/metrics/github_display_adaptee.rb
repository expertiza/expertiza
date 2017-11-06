class GithubDisplayAdapter < MetricDisplayAdapter
  def initialize(metrics)
    @metrics = metrics 
  end

  def get_raw_data
    @metrics
  end
  
  def to_bar_graph
    data = reduce_commits_to_user_stats(@metrics)
    if ! data.nil? && ! data.empty?
      result = data.map { | k, v | [k, v[:lines_added], v[:lines_deleted]]}
      result.unshift(["Email", "Additions", "Deletions"])
    else 
      ["Email", "Additions", "Deletions"]
    end
  end
  end

  private >>

  def reduce_commits_to_user_stats(metrics) 
    if ! metrics.nil? 
      default = {:count => 0, :total => 0}
      metrics.reduce(Hash.new(default)) { | total, commit |
        oldrow = total[commit[:email]]
        newrow = { 
          :count => oldrow[:count] + 1,
          :additions => oldrow[:lines_added] + commit[:lines_added],
          :additions => oldrow[:lines_deleted] + commit[:lines_deleted],
          :total => oldrow[:lines_changed] + commit[:lines_changed]
        }
        total.update(commit[:email] => newrow)
    }
    end
  end
end