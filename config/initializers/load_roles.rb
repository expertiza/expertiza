require 'credentials'
require 'menu'
CACHED_STUDENT_MENU = YAML.load_file("#{Rails.root}/config/role_student.yml")[Rails.env]
CACHED_ADMIN_MENU = YAML.load_file("#{Rails.root}/config/role_admin.yml")[Rails.env]
CACHED_SUPER_ADMIN_MENU = YAML.load_file("#{Rails.root}/config/role_super_admin.yml")[Rails.env]
CACHED_INSTRUCTOR_MENU = YAML.load_file("#{Rails.root}/config/role_instructor.yml")[Rails.env]
CACHED_UNREG_USER_MENU = YAML.load_file("#{Rails.root}/config/role_unreg_user.yml")[Rails.env]
CACHED_TA_MENU = YAML.load_file("#{Rails.root}/config/role_ta.yml")[Rails.env]

CACHED_ROLES = { 1 => CACHED_STUDENT_MENU,
                 2 => CACHED_INSTRUCTOR_MENU,
                 3 => CACHED_ADMIN_MENU,
                 4 => CACHED_SUPER_ADMIN_MENU,
                 5 => CACHED_UNREG_USER_MENU,
                 6 => CACHED_TA_MENU }.freeze
