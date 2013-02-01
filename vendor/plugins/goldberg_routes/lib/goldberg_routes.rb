# GoldbergRoutes


module GoldbergRoutes
  def self.included(base)
    base.class_eval do
      alias_method :draw_without_goldberg_routes, :draw
      alias_method :draw, :draw_with_goldberg_routes
    end
  end

  def draw_with_goldberg_routes(&block)
    
    draw_without_goldberg_routes do |map|
      block.call map 
    end

    routes = [ 
              ['', 
               {:controller => "content_pages", :action => "view_default"}],

              ['menu/*name', 
               {:controller => 'menu_items', :action => 'link'}],

              ['*page_name', 
               {:controller => "content_pages", :action => "view"}]
             ]

    route_method = ActionController::Routing::Routes.respond_to?(:add_route)? 
    :add_route : :connect

    for route in routes do
      ActionController::Routing::Routes.send(route_method, *route)
    end

    # Install the new routes (Rails 1.1 only)
    if ActionController::Routing::Routes.respond_to? :write_generation and
        ActionController::Routing::Routes.respond_to? :write_recognition
      ActionController::Routing::Routes.write_generation
      ActionController::Routing::Routes.write_recognition
    end 
  
  end
end

ActionController::Routing::RouteSet.class_eval do
  include GoldbergRoutes
end
