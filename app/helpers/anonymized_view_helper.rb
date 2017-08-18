module AnonymizedViewHelper
  def is_anonymous_mode?
    session[:anonymous_mode]
  end
  def anonymize(name)
    ((name.sum)%50)+1
  end
  def display_anon_fullname(name)
    name_array=name.split(',')
    return AnonymizedLastName.find(anonymize(name_array[-1])).name + ", "+ AnonymizedFirstName.find(anonymize(name_array[0])).name if is_anonymous_mode?
    return name
  end
  def display_anon_name(name)
    return AnonymizedFirstName.find(anonymize(name)).name if is_anonymous_mode?
    return name
  end
  def display_anon_mail(name)
    return display_anon_handle(name) + "@address.com" if is_anonymous_mode?
    return name
  end
  def display_anon_handle(name)
    return AnonymizedFirstName.find(anonymize(name)).name.downcase if is_anonymous_mode?
    return name
  end
end