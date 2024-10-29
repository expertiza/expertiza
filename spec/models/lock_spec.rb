# This test was added for E1973:
# http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_Project_E1973._Team_Based_Reviewing
# For this project, it was only necessary that responses be locked. If you plan on using Lock for another model,
# You should add cases for that model to this test.
describe Lock do
  # Locks interact with the database. Since we want to check database values, we need to use the database
  before(:each) do
    # I was unable to use regular create! calls for user.
    # I think this might be because the writers of user.rb overrode User.initialize
    @smyoder = User.new(username: 'smyoder', name: 'John Bumgardner', email: 'smyoder@ncsu.edu')
    @smyoder.save!

    @smyoder1 = User.new(username: 'smyoder1', name: 'John Bumgardner', email: 'smyoder1@ncsu.edu')
    @smyoder1.save!
    @response = Response.create!(round: 1)
  end

  # We don't want to pollute the database
  after(:each) do
    @smyoder.destroy!
    @smyoder1.destroy!
    @response.destroy!
  end

  # This just ensures that locks have the correct dependencies
  # If another model is added to be locked someday, it may be useful to add more tests here
  it 'Should be able to be created for a user and a response and be destroyed when one of those is destroyed' do
    lock = Lock.create!(user: @smyoder, lockable: @response, timeout_period: 10)
    expect(Lock.find_by(user: @smyoder, lockable: @response)).to eq(lock)
    @smyoder.destroy!
    expect(Lock.find_by(user: @smyoder, lockable: @response)).to be_nil
    lock = Lock.create!(user: @smyoder1, lockable: @response, timeout_period: 10)
    expect(Lock.find_by(user: @smyoder1, lockable: @response)).to eq(lock)
    @response.destroy!
    expect(Lock.find_by(user: @smyoder1, lockable: @response)).to be_nil
  end

  describe '#get_lock' do
    it 'Should create new locks when a user requests them' do
      # smyoder should have a lock on the response for 10 minutes
      expect(Lock.get_lock(@response, @smyoder, 10)).to eq(@response)
      firstLock = Lock.find_by(user: @smyoder, lockable: @response)
      expect(firstLock).not_to be_nil
      # A user with a lock on a resource should be able to renew the lock
      expect(Lock.get_lock(@response, @smyoder, 8)).to eq(@response)
      secondLock = Lock.find_by(user: @smyoder, lockable: @response)
      expect(secondLock).not_to eq(firstLock)
    end

    it 'Should return nil when a user tries to get a locked on a locked resource' do
      expect(Lock.get_lock(@response, @smyoder, 10)).to eq(@response)
      expect(Lock.get_lock(@response, @smyoder1, 10)).to be_nil
    end

    it 'Should allow a user to take a lock from a user whose lock time has expired' do
      # This lock will expire after 0 minutes
      expect(Lock.get_lock(@response, @smyoder, 0)).to eq(@response)
      expect(Lock.get_lock(@response, @smyoder1, 10)).to eq(@response)
      expect(Lock.get_lock(@response, @smyoder, 1)).to be_nil
    end
  end

  describe '#release_lock' do
    it 'Should allow different users to acquire a lock which was formerly unavailable' do
      expect(Lock.get_lock(@response, @smyoder, 10)).to eq(@response)
      expect(Lock.get_lock(@response, @smyoder1, 10)).to be_nil
      Lock.release_lock(@response)
      expect(Lock.get_lock(@response, @smyoder1, 10)).to eq(@response)
      expect(Lock.get_lock(@response, @smyoder, 10)).to be_nil
    end

    it 'Should not throw errors when releasing locks that don\'t exist' do
      Lock.release_lock(@response)
      # No error should be thrown
    end
  end

  describe '#lock_between?' do
    it 'Should correctly report when users do own locks on resources' do
      expect(Lock.get_lock(@response, @smyoder, 10)).to eq(@response)
      expect(Lock.lock_between?(@response, @smyoder)).to be true
    end

    it 'Should correctly report when users do not own locks on resources' do
      expect(Lock.lock_between?(@response, @smyoder)).to be false
      expect(Lock.get_lock(@response, @smyoder1, 10)).to eq(@response)
      expect(Lock.lock_between?(@response, @smyoder)).to be false
    end

    it 'Should correctly interact with the timeout period of locks' do
      expect(Lock.get_lock(@response, @smyoder, 0)).to eq(@response)
      expect(Lock.lock_between?(@response, @smyoder)).to be true
      expect(Lock.get_lock(@response, @smyoder1, 0)).to eq(@response)
      expect(Lock.lock_between?(@response, @smyoder)).to be false
      Lock.release_lock(@response)
      expect(Lock.lock_between?(@response, @smyoder)).to be false
    end
  end
end
