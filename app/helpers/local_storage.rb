#LocalStorage implementation using PStore
class LocalStorage
  def initialize()
    @registry = []
    @pstore = PStore.new("local_submitted_content.pstore")
    @pstore.transaction do
      @pstore[:registry] ||= []
    end
    @registry = read
  end

  #saves an instance of LocalSubmittedContent to pstore file and pushes to registry list
  def save(instance)
    @pstore.transaction do
      @registry << instance
      @pstore[:registry] = @registry
    end
  end

  #Ensures the registry list and pstore file always have the same instances
  def sync()
    @pstore.transaction do
      @pstore[:registry] = @registry
    end
  end

  # Find all entries that meet every field in the params hash
  # return list of matching entries
  def where(params)
    found = []

    @registry.each do |item|
      if item.to_h.values_at(*params.keys) == params.values
        found << item
      end
    end
    found
  end

  # Reads and returns data from Pstore registry
  def read
    @pstore.transaction do
      return @pstore[:registry]
    end
  end

  # Actually saves into the database
  def hard_save(instance)
    SubmissionViewingEvent.create(instance.to_h)
  end

  # Actually saves all instances in registry list to database
  def hard_save_all
    @registry.each do |item|
      SubmissionViewingEvent.create(item.to_h)
    end
  end

  #Removes instance from registry list then syncs to update pstore file
  def remove(instance)
    @registry.each_with_index do |item, i|
      if item.to_h == instance.to_h
        @registry.delete_at(i)
      end
    end
    sync
  end

  #Clears registry and PStore file
  def remove_all
    @registry = []
    sync
  end
end