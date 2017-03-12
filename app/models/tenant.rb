class Tenant < ActiveRecord::Base
  has_many :tenant_users
  has_many :tool_deployments
  has_many :iresources

  validates :tenant_name, :uniqueness => true

  def to_s
    tenant_name
  end
end
