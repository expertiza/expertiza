require './loader/github_loader_adaptee'

class MetricsFactory 

  self.LOADER_ADAPTERS=[GithubLoaderAdapter]

  def self.load_metric(params) 
    for a in self.LOADER_ADAPTERS do
      url = params[:url]

      if a.can_load?(url) 
        return GithubDisplayAdapter(load_metric(params))
      end
    end
  end

  
end