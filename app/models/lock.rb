# This class was added to facilitate functionality in E1973:
# http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
# But was generalized at the behest of Dr. Gehringer.
# The purpose of this model is to help facilitate the locking of edits of models, or more specifically,
# To facilitate the locking of the pages which allow for modification of an object.
# Because this was made for that purpose, ActiveRecord.lock! is not used on the resource. However, it may be useful
# for you if you wish to use this to implement a lock just on a database entry.
# There is information here: https://api.rubyonrails.org/v5.2.3/classes/ActiveRecord/Locking/Pessimistic.html
class Lock < ActiveRecord::Base
  #The resource being locked can be any class
  belongs_to :lockable, foreign_key: 'lockable_id', polymorphic: true, inverse_of: false
  belongs_to :user, class_name: 'User', foreign_key: 'user_id', inverse_of: false
  # How many minutes of inactivity before this lock is released?
  validates :timeout_period, presence: true
  
  # Requests a lock on the given resource for the given user
  # Since resources can be of any class, the class name for the resource must be provided
  # Return the resource if it's available or nil if it is not
  # Automatically handles creating/destroying locks and timeout periods
  # However, once a user is done with a lock, it is their responsibility to destroy it by using Lock.unlock
  def self.lock(lockable, user)
    if(lockable.nil? || user.nil?)
      return nil
    end
    # lockable_id is a special id just for this class since it has polymorphic resources
    # Also use an actual database lock to prevent race conditions
    lock = find_by(lockable_id: lockable.lockable_id, user_id: user.id)
    if lock.nil?
      return create_lock(lockable, user.id)
    end
    # We need to put an actual database lock on this object to prevent concurrent acquisition of this object
    # If two users were to request a lock at the same time, they might otherwise be able to acquire this lock simultaneously
    lock.with_lock do
      # If the timeout period is up, the lock is fair game
      if lock.created_at + timeout_period.minutes <= DateTime.now
        lock.destroy
        return create_lock(lockable, user.id)
      end
      # Your last chance on acquiring the lock is if you already own it
      if(lock.user_id == user.id)
        lock.destroy
        return create_lock(lockable, user.id)
      end
    end
    # Return nil because a lock could not be obtained on the resource
    return nil
  end
  
  # Checks to see if there exists a lock between the given resource and user
  # If I am a user who uses a resource for so long that the timeout period has passed AND another
  # user has locked, modified, and unlocked the resource, I do NOT want to modify the resource
  # even though it may be unlocked. This method should always be checked before any database
  # changes are made.
  def self.lock_between?(lockable, user)
    return !find_by(lockable_id: lockable.id, user_id: user.id).nil?
  end
  
  #Destroys the lock on the given resource by the given user (if it exists)
  def self.unlock(lockable, user)
    if lockable.nil? || user.nil?
      return
    end
    lock = find_by(lockable_id: lockable.lockable_id, user_id: user.id)
    if !lock.nil?
      lock.destroy
    end
  end
  
  private
  # Just a little helper method to help keep this code DRY
  # If for some reason, the lock had trouble being created, returns nil because there is no
  # lock on the object
  def self.create_lock(lockable, user_id)
    # This could be a potential location for a race condition; however, based on what I've read,
    # if two users make calls to create, one will get the object and the other will get nil.
    if Lock.create(lockable: lockable, user_id: user_id).nil?
      return nil
    end
    return lockable
  end
end
