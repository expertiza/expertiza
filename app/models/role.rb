require 'credentials'
require 'menu'

class Role < ApplicationRecord
  belongs_to :parent, class_name: 'Role', inverse_of: false
  has_many :users, inverse_of: false, dependent: :nullify

  serialize :cache
  validates :name, presence: true
  validates :name, uniqueness: true

  # rubocop:disable Lint/DuplicateMethods
  attr_accessor :cache
  attr_reader :student, :ta, :instructor, :administrator, :superadministrator

  def cache
    @cache = {}
    unless nil?
      @cache[:credentials] = CACHED_ROLES[id][:credentials]
      @cache[:menu] = CACHED_ROLES[id][:menu]
    end
    @cache
  end
  # rubocop:enable Lint/DuplicateMethods

  def self.find_or_create_by_name(params)
    Role.find_or_create_by(name: params)
  end

  def self.student
    @student_role ||= find_by name: 'Student'
  end

  def student?
    name['Student']
  end

  def instructor?
    name['Instructor']
  end

  def ta?
    name['Teaching Assistant']
  end

  def admin?
    name['Administrator'] || super_admin?
  end

  def self.ta
    @ta_role ||= find_by name: 'Teaching Assistant'
  end

  def self.instructor
    @instructor_role ||= find_by name: 'Instructor'
  end

  def self.administrator
    @administrator_role ||= find_by name: 'Administrator'
  end

  def self.admin
    administrator
  end

  def self.superadministrator
    @superadministrator_role ||= find_by name: 'Super-Administrator'
  end

  def super_admin?
    name['Super-Administrator']
  end

  def self.super_admin
    superadministrator
  end

  def self.rebuild_cache
    Role.find_each do |role|
      role.cache = {}
      role.rebuild_credentials
      role.rebuild_menu
    end
  end

  def other_roles
    Role.where('id != ?', id).order(:name)
  end

  def rebuild_credentials
    cache[:credentials] = CACHED_ROLES[id][:credentials]
  end

  def rebuild_menu
    cache[:menu] = CACHED_ROLES[id][:menu]
  end

  # return ids of roles that are below this role
  def get_available_roles
    ids = []

    current = parent_id
    while current
      role = Role.find(current)
      next unless role

      unless ids.index(role.id)
        ids << role.id
        current = role.parent_id
      end
    end
    ids
  end

  # "parents" are lesser roles. This returns a list including this role and all lesser roles.
  def get_parents
    parents = []
    seen = {}

    current = id

    while current
      role = Role.find(current)
      if role
        if seen.key?(role.id)
          current = nil
        else
          parents << role
          seen[role.id] = true
          current = role.parent_id
        end
      else
        current = nil
      end
    end

    parents
  end

  # determine if the current role has all the privileges of the parameter role
  # If the current role is the same as the parameter role, return true
  # That is, use greater-than-or-equal-to logic

  def has_all_privileges_of?(target_role)
    privileges = {}
    privileges['Student'] = 1
    privileges['Teaching Assistant'] = 2
    privileges['Instructor'] = 3
    privileges['Administrator'] = 4
    privileges['Super-Administrator'] = 5

    privileges[name] >= privileges[target_role.name]
  end

  def update_with_params(role_params)
    self.name = role_params[:name]
    self.parent_id = role_params[:parent_id]
    self.description = role_params[:description]
    save
  rescue StandardError
    false
  end
end
