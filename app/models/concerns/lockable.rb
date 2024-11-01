module Lockable
  extend ActiveSupport::Concern

  included do
    has_one :lock, as: :lockable, dependent: :destroy
  end
end
