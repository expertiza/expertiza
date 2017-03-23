# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  @@cache_roles = { 1 => CACHED_STUDENT_MENU, 2 => CACHED_INSTRUCTOR_MENU,
                    3 => CACHED_ADMIN_MENU, 4 => CACHED_SUPER_ADMIN_MENU,
                    5 => CACHED_UNREG_USER_MENU, 6 => CACHED_TA_MENU }

  def is_available(user, owner_id)
    user.id == owner_id ||
      user.admin? ||
      user.super_admin?
  end

  def get_cache_roles(id)
    @@cache_roles[id]
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
end
