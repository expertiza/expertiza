require "credentials"
require "menu"

class Role < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Role'
  has_many :users

  serialize :cache
  validates_presence_of :name
  validates_uniqueness_of :name

  attr_reader :student,:ta,:instructor,:administrator,:superadministrator

  def self.find_or_create_by_name (params)
    Role.find_or_create_by(name: params)
  end


  def self.student
    @@student_role ||= find_by_name 'Student'
  end

  def student?
    name['Student']
  end

  def admin?
    name['Administrator'] || super_admin?
  end

  def self.ta
    @@ta_role ||= find_by_name 'Teaching Assistant'
  end

  def self.instructor
    @@instructor_role ||= find_by_name 'Instructor'
  end

  def self.administrator
    @@administrator_role ||= find_by_name 'Administrator'
  end

  def self.admin
    administrator
  end

  def self.superadministrator
    @@superadministrator_role ||= find_by_name 'Super-Administrator'
  end

  def super_admin?
    name['Super-Administrator']
  end

  def self.super_admin
    superadministrator
  end

  def Role.rebuild_cache
    Role.find_each do |role|
      role.cache = nil
      role.save # we have to do this to clear it

      role.cache = Hash.new
      role.rebuild_credentials
      role.rebuild_menu
      role.save
    end
  end

  def other_roles
    Role.where('id != ?', id).order(:name)
  end

  def rebuild_credentials
    self.cache[:credentials] = Credentials.new(self.id)
  end


  def rebuild_menu
    menu = Menu.new(self)
    self.cache[:menu] = menu
  end

  # return ids of roles that are below this role
  def get_available_roles
    ids = Array.new

    current = self.parent_id
    while current
      role = Role.find(current)
      if role
        if not ids.index(role.id)
          ids << role.id
          current = role.parent_id
        end
      end
    end
    return ids
  end

  # "parents" are lesser roles. This returns a list including this role and all lesser roels.
  def get_parents
    parents = Array.new
    seen = Hash.new

    current = self.id

    while current
      role = Role.find(current)
      if role
        if not seen.has_key?(role.id)
          parents << role
          seen[role.id] = true
          current = role.parent_id
        else
          current = nil
        end
      else
        current = nil
      end
    end

    return parents
  end

end
