class Array
  def equality_uniq
    uniq_elements = []
    self.each {|e| uniq_elements.push(e) unless uniq_elements.index(e)}
    uniq_elements
  end

  def delete_at_indices(indices = [])
    not_deleted = Array.new
    self.each_with_index {|e,i| not_deleted.push(e) if !indices.include?(i)} 
    not_deleted
  end
end

class DefaultInitArray < Array
  def initialize(*args, &initblock)
    super(*args)
    @initblock = initblock
  end

  def [](index)
    super(index) || (self[index] = @initblock.call(index))
  end
end

class ArrayOfArrays < DefaultInitArray
  @@create_array = proc{|i| Array.new}
  def initialize(*args)
    super(*args, &@@create_array)
  end
end

class ArrayOfHashes < DefaultInitArray
  @@create_hash = proc{|i| Hash.new}
  def initialize(*args)
    super(*args, &@@create_hash)
  end
end

# Hash which takes a block that is called to give a default value when a key
# has the value nil in the hash.
class DefaultInitHash < Hash
  def initialize(*args, &initblock)
    super(*args)
    @initblock = initblock
  end

  def [](key)
    super(key) || (self[key] = @initblock.call(key))
  end
end

unless Object.constants.include?("TimesClass")
  TimesClass = (RUBY_VERSION < "1.7") ? Time : Process
end

def time_and_puts(string, &block)
  if $TIME_AND_PUTS_VERBOSE
    print string; STDOUT.flush
  end
  starttime = [Time.new, TimesClass.times]
  block.call
  endtime = [Time.new, TimesClass.times] 
  duration = endtime[0] - starttime[0]
  begin
    load = [((endtime[1].utime+endtime[1].stime)-(starttime[1].utime+starttime[1].stime))/duration*100.0, 100.0].min
    puts " (%.2f s %.2f%%)" % [duration, load] if $TIME_AND_PUTS_VERBOSE
  rescue FloatDomainError
  end
end
