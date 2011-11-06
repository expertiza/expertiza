require "#{File.dirname(__FILE__)}/enumeration"
require 'date'

class Raketab  
  Month   = enum %w[January February March April May June July August September October November December], 1
  Weekday = enum %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    
  class << self
    def methodize_enum(enum)
      enum.each do |e| 
        p = Proc.new { e }
        define_method(e.to_s.downcase,    p) 
        define_method(e.to_abbr.downcase, p) 
      end
    end
    private :methodize_enum

    def schedule(&block)
      tab = Raketab.new
      tab.instance_eval(&block)
      tab
    end
  end
  methodize_enum(Month)
  methodize_enum(Weekday)
  
  def initialize
    @tabs = []
  end

  def run(command, options={})
    month, wday, mday, hour, min = options[:month]   || options[:months]   || options[:mon], 
                                   options[:weekday] || options[:weekdays] || options[:wday], 
                                   options[:day]     || options[:days]     || options[:mday],
                                   options[:hour]    || options[:hours],
                                   options[:minute]  || options[:minutes]  || options[:min]

    # make sure we have ints instead of enums, yo
    month, wday = [[month, Month], [wday, Weekday]].map do |element,type| 
      if element.kind_of?(Array) # just arrays for now
       element.each_with_index { |e,i| element[i] = enum_to_i(e,type) } 
      else
       enum_to_i(element,type)
      end
    end

    [:each, :every, :on, :in, :at, :the].each do |type|
      if options[type]
        if(options[type] =~ /:/)
          from = options[type]
        else
          from, ignore, exclusive, to = options[type].to_s.match(/(\w+)(\.\.(\.?)(\w+))?/)[1..4].map { |m| m.gsub(/s$/i, '') if m } 
        end

        parse = Date._parse(from)
        range = to ? Date._parse(to) : {}

        month ||= get_value(parse, range, exclusive == '.', :mon)
        wday  ||= get_value(parse, range, exclusive == '.', :wday)
        mday  ||= get_value(parse, range, exclusive == '.', :mday)
        hour  ||= get_value(parse, range, exclusive == '.', :hour)
        min   ||= get_value(parse, range, exclusive == '.', :min)
      end
    end

    # deal with any arrays and ranges
    min, hour, mday, wday, month = [min, hour, mday, wday, month].map do |type| 
     type.respond_to?(:map) ? type.map.join(',') : type    
    end

    # special cases with hours
    hour ||= options[:at].to_i if options[:at] # :at => "5 o'clock" / "5" / 5

    # fill missing items
    hour, min         = [hour, min].map { |t| t || '0' }
    month, wday, mday = [month, wday, mday].map { |t| t || '*' }    
    
    # put it together
    @tabs << "#{min} #{hour} #{mday} #{month} #{wday} #{command}"
  end  

  def tabs
    @tabs.join("\n")
  end

  private
    def get_value(from, to, exclusive, on)
      value = (from[on] and to[on]) ? Range.new(from[on], to[on], exclusive) : from[on]
      if value.is_a?(Range) and value.first > value.last
        reverse = (value.last.to_i+(exclusive ? 0 : 1)..(value.first.to_i-1))
        range = case on
          when :mon  then 1..12
          when :wday then 0..6
          when :mday then 1..31
        end
        value = range.map - reverse.map
      end
      value
    end

    def enum_to_i(element, type)
      element.kind_of?(type) ? element.to_i : element
    end
end  
