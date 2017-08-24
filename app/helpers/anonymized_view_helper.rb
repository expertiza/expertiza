module AnonymizedViewHelper
  
  def anonymous_mode?
    session[:anonymous_mode]
  end
  
  def anonymize(name)
    name.sum % 50 + 1
  end
  
  # All the below functions will return anonmized names if mode is sset or  else just return name as is.
  def display_anon_fullname(name)
    name_array = name. split(',')
    return AnonymizedLastName.find(anonymize(name_array[-1])).name + ", " + AnonymizedFirstName.find(anonymize(name_array[0])).name if anonymous_mode?
    name
  end
  
  def display_anon_name(name)
    return AnonymizedFirstName.find(anonymize(name)).name if anonymous_mode?
    name
  end
  
  def display_anon_mail(name)
    name_array = name. split('@')
    return display_anon_handle(name_array[0]) + "@mailinator.com" if anonymous_mode?
    name
  end
  
  def display_anon_handle(name)
    return AnonymizedFirstName.find(anonymize(name)).name.downcase if anonymous_mode?
    name
  end

end