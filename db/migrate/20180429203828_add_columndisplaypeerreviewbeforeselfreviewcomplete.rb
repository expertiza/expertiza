#E1819
class AddColumndisplaypeerreviewbeforeselfreviewcomplete < ActiveRecord::Migration
  def change
    add_column :assignments, :display_peer_review_before_self_review_complete, :boolean
  end
end
