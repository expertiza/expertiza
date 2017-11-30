require './loader/github_loader_adaptee'
require './loader/trello_loader_adaptee'

class MetricsFactory

  self.LOADER_ADAPTERS=[GithubLoaderAdapter, TrelloLoaderAdapter]

  def self.load_metric(params)
    for a in self.LOADER_ADAPTERS do
      if a == GithubLoaderAdapter
        url = params[:url]

        if a.can_load?(url)
          return GithubDisplayAdapter(load_metric(params))
        end
      elsif a == TrelloLoaderAdapter
        url = params[:url]

        if a.can_load?(url)
          return true
        end
      end
    end
  end


end
