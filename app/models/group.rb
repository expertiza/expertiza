class Group < Team
  has_many :groups_users, dependent: :destroy
  has_many :users, through: :groups_users
  has_many :join_group_requests
end
