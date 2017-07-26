# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_available(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  # Make a new user of the same class
  def self.get_user_role(l_user)
    eval "#{l_user.role.name.delete('-')}.new"
  end

  def self.get_user_first_name(recipient)
    recipient.first_name
  end

  def get_field(element, field)
    element.send field
  end

  def flash_message(type)
    "<div class='flash_#{type}'>#{flash[type]}</div>".html_safe if flash[type]
  end

  def text_field_with_auto_complete model, field, options
    text_field_tag "#{model}[#{field}]", "", options
  end
  def get_anonymous_mode
    session[:mode]
  end
  def anonymize(name)
    (name.sum)%50
  end
  def display_anon_name(name)
    if (session[:mode])
      return anonymize(name)
    else
      return name
    end
  end
end
