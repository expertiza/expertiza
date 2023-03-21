class AddHandleToParticipants < ActiveRecord::Migration[4.2]
  def self.up
    add_column :participants, :handle, :string, null: true
    AssignmentParticipant.find_each do |participant|
      if participant.handle.nil?
        user = User.find(participant.user_id)
        participant.handle = if user.handle.nil?
                               user.name
                             else
                               user.handle
                             end
        participant.save
      end
    end
  rescue StandardError
    put $ERROR_INFO
  end

  def self.down
    remove_column :users, :handle
  rescue StandardError
  end
end
