class Credentials
  attr_accessor :role_id, :updated_at, :role_ids
  attr_accessor :permission_ids
  attr_accessor :controllers, :actions, :pages

  # Create a new credentials object for the given role
  def initialize(role_id)
    @role_id = role_id

    role = Role.find(@role_id)
    @updated_at = role.updated_at

    @role_ids = role.get_parents.map(&:id)
  end
end
