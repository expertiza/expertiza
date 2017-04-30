class Tenant < ActiveRecord::Base
  validates :tenant_name, :uniqueness => true

  def to_s
    tenant_name
  end
end