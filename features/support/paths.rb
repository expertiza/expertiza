module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page|the login page/
      '/'
<<<<<<< HEAD
=======
    when /the new feature page/
      new_feature_path

    when /the new login page/
      new_login_path

>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
    
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
<<<<<<< HEAD
=======
    when /manage my team/
      current_url

    when /edit my team/
      current_url
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
