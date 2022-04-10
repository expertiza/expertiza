# This class was added to facilitate functionality in E1973:
# http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
# But was generalized at the behest of Dr. Gehringer.
# The purpose of this model is to help facilitate the locking of edits of models, or more specifically,
# To facilitate the locking of the pages which allow for modification of an object.
# Because this was made for that purpose, ActiveRecord.lock! is not used on the resource. However, it may be useful
# for you if you wish to use this to implement a lock just on a database entry.
# There is information here: https://api.rubyonrails.org/v5.2.3/classes/ActiveRecord/Locking/Pessimistic.html
class Lock < ApplicationRecord
  # The resource being locked can be any class
  belongs_to :lockable, polymorphic: true
  belongs_to :user, class_name: 'User', foreign_key: 'user_id', inverse_of: false
  # How many minutes of inactivity before this lock is released?
  validates :timeout_period, presence: true

  # For E1973, we're just going to use the default timeout period of 20 minutes.
  DEFAULT_TIMEOUT = 20

  # Requests a lock on the given resource for the given user
  # Since resources can be of any class, the class name for the resource must be provided
  # Return the resource if it's available or nil if it is not
  # Automatically handles creating/destroying locks and timeout periods
  # However, once a user is done with a lock, it is their responsibility to destroy it by using Lock.unlock
  def self.get_lock(lockable, user, timeout)
    return nil if lockable.nil? || user.nil?

    lock = find_by(lockable: lockable)
    return create_lock(lockable, user, timeout) if lock.nil?

    # We need to put an actual database lock on this object to prevent concurrent acquisition of this object
    # If two users were to request a lock at the same time, they might otherwise be able to acquire this lock simultaneously
    lock.with_lock do
      # If the timeout period is up, the lock is fair game
      if lock.created_at + lock.timeout_period.minutes <= DateTime.now
        lock.destroy
        return create_lock(lockable, user, timeout)
      end
      # Your last chance on acquiring the lock is if you already own it
      if lock.user_id == user.id
        lock.destroy
        return create_lock(lockable, user, timeout)
      end
    end
    # Return nil because a lock could not be obtained on the resource
    nil
  end

  # Checks to see if there exists a lock between the given resource and user
  # If I am a user who uses a resource for so long that the timeout period has passed AND another
  # user has locked, modified, and unlocked the resource, I do NOT want to modify the resource
  # even though it may be unlocked. This method should always be checked before any database
  # changes are made.
  # It should be noted that this will return true even after the timeout period has passed.
  # Since this method is for doing safety checks, if no one else has acquired the lock, it's okay to
  # make edits.
  # This method will also renew the timeout period on the lock to avoid race conditions
  def self.lock_between?(lockable, user)
    lock = find_by(lockable_id: lockable.id, user_id: user.id)
    if lock.nil?
      return false
    else
      lock.destroy
      create_lock(lockable, user, lock.timeout_period)
      return true
    end
  end

  # Destroys the lock on the given resource by the given user (if it exists)
  def self.release_lock(lockable)
    return if lockable.nil?

    lock = find_by(lockable: lockable)
    Lock.where(lockable: lockable).destroy_all unless lock.nil?
  end

  # Just a little helper method to help keep this code DRY
  # If for some reason, the lock had trouble being created, returns nil because there is no
  # lock on the object
  def self.create_lock(lockable, user, timeout)
    # This method is still a potential location for a race condition.
    # Unfortunately, database locks can't be created for nonexistent entries.
    # This was the way I found online avoid the race condition but I'm not sure exactly how it works
    transaction do
      lock = Lock.new(lockable: lockable, user: user, timeout_period: timeout)
      lock.save!
      return lockable
    end
  end
end
