module Morpher
  class Printer

    # Printer behavior mixin
    module Mixin

      # Class level methods to be mixed in
      module ClassMethods

        # Register printer block for class
        #
        # @return [self]
        #
        # @api private
        #
        def printer(&block)
          REGISTRY[self] = block
        end

      end # ClassMethods

      # Instance level methods to be mixed in
      module InstanceMethods

        # Return description
        #
        # @return [String]
        #
        # @api private
        #
        def description
          io = StringIO.new
          Printer.run(self, io)
          io.rewind
          io.read
        end

      end # InstanceMethods

      # Callback whem module gets included
      #
      # @param [Class, Module] descendant
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.included(descendant)
        descendant.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end
      private_class_method :included

    end # Mixin
  end # Printer
end # Morpher
