module Delayed
  class DelayProxy < ActiveSupport::BasicObject
    def initialize(target, options)
      @target = target
      @options = options
    end

    def method_missing(method, *args)
      Job.create({
        :payload_object => PerformableMethod.new(@target, method.to_sym, args),
        :priority       => ::Delayed::Worker.default_priority
      }.merge(@options))
    end
  end

  module MessageSending
    def delay(options = {})
      DelayProxy.new(self, options)
    end
    alias __delay__ delay
    
    def send_later(method, *args)
      warn "[DEPRECATION] `object.send_later(:method)` is deprecated. Use `object.delay.method"
      __delay__.__send__(method, *args)
    end

    def send_at(time, method, *args)
      warn "[DEPRECATION] `object.send_at(time, :method)` is deprecated. Use `object.delay(:run_at => time).method"
      __delay__(:run_at => time).__send__(method, *args)
    end
    
    module ClassMethods
      def handle_asynchronously(method, opts = {})
        aliased_method, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
        with_method, without_method = "#{aliased_method}_with_delay#{punctuation}", "#{aliased_method}_without_delay#{punctuation}"
        define_method(with_method) do |*args|
          curr_opts = opts.clone
          curr_opts.each_key do |key|
            if (val = curr_opts[key]).is_a?(Proc)
              curr_opts[key] = if val.arity == 1
                val.call(self)
              else
                val.call
              end
            end
          end
          delay(curr_opts).__send__(without_method, *args)
        end
        alias_method_chain method, :delay
      end
    end
  end                               
end
