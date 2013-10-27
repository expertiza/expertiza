class Enumeration  
  include Comparable

  def initialize(id)
    @unit_id = id % self.class.size
  end
  private_class_method :new
  
  def self.for(var)
    units[var.to_s =~ /^\d+$/ ? var.to_i - offset : abbrs.index(var[0,3].downcase.capitalize)] 
  end

  def succ
    self.class.units[(@unit_id + 1) % self.class.size]
  end

  def between?(a,b)
    true # always in rings, change for non rings
  end
  
  def <=>(o)
    @unit_id <=> o.instance_variable_get("@unit_id")
  end
  
  def to_s
    self.class.names[@unit_id]
  end
  
  def to_i
    @unit_id + self.class.offset
  end
  
  def to_abbr
    to_s[0,3]
  end
  
  def coerce(o)
    [self.class.for(o % self.class.size), self]
  end

  def +(o)
    self.class.for((to_i + o.to_i) % self.class.size)
  end

  def -(o)
    self.class.for((to_i - o.to_i) % self.class.size)
  end

  def inspect
    "#<#{self.class.name.split("::").last}:#{to_s}>"
  end
      
  def self.generate(names, offset=0)
    klass = Class.new(self)
    klass.send(:build_from, names)
    klass.send(:offset=, offset)
    klass.instance_eval { undef generate } 
    klass
  end

  class << self
    include Enumerable
    def each
      units.each { |u| yield u }
    end
    
    attr_accessor :offset
    attr_reader :names, :abbrs, :units, :size
    def build_from(names)
      @names = names.dup.freeze
      @abbrs = names.map { |n| n[0,3] }.freeze

      @size  = @names.size
      @units = (0...@size).map { |n| new(n) }.freeze

      @names.each_with_index do |c,i|
        const = c.upcase
        const_get(const)      rescue const_set(const, @units[i]) 
        const_get(const[0,3]) rescue const_set(const[0,3], @units[i]) 
      end
    end
    private :build_from
  end
end

def Enumeration(*args)
  Enumeration.generate(*args)
end
alias enum Enumeration