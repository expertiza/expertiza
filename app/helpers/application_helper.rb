# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_available(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  # Make a new user of the same class
  def self.get_user_role(l_user)
    eval "#{l_user.role.name.gsub(/-/, '')}.new"
  end

  def self.get_user_first_name(recipient)
    recipient.first_name
  end

  def get_field(element, field)
    element.send field
  end

  def flash_message(type)
    if flash[type]
      "<div class='flash_#{type.to_s}'>#{flash[type]}</div>".html_safe
    end
  end

  def text_field_with_auto_complete model, field, options
    text_field_tag "#{model}[#{field}]", "", options
  end
end
