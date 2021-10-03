module Morpher

  # Evaluation and Evaluator pretty printer
  class Printer
    include Adamantium::Flat, Concord.new(:object, :output, :indent_level)

    INDENT = '  '.freeze

    REGISTRY = {}

    # Run pretty printer on object
    #
    # @param [Object] object
    #   the object to be pretty printed
    # @param [IO] output
    #   the output to write to
    # @param [Fixnum] indent_level
    #   the current indentation level
    #
    # @return [self]
    #
    # @api private
    #
    def self.run(object, output, indent_level = 0)
      printer = new(object, output, indent_level)
      block = lookup(object)
      printer.instance_eval(&block)
    end

    # Perform type lookup
    #
    # FIXME: Instanciate type lookup once and allow caching.
    #
    # @param [Evaluation, Evaluator] object
    #
    # @return [Proc]
    #   if found
    #
    # @raise [PrinterMissingException]
    #   otherwise
    #
    # @api private
    #
    def self.lookup(object)
      TypeLookup.new(REGISTRY).call(object)
    end

  private

    # Visit a child
    #
    # @param [Node] child
    #
    # @api private
    #
    # @return [undefined]
    #
    def visit_child(child)
      self.class.run(child, output, indent_level.succ)
    end

    # Visit a child by name
    #
    # @param [Symbol] name
    #   the attribute name of the child to visit
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit(name)
      child = object.public_send(name)
      child_label(name)
      visit_child(child)
    end

    # Visit many children
    #
    # @param [Symbol] name
    #   the name of the collection attribute with children to visit
    #
    # @return [undefined]
    #
    # @api private
    #
    def visit_many(name)
      children = object.public_send(name)
      child_label(name)
      children.each do |child|
        visit_child(child)
      end
    end

    # Print attribute class
    #
    # @param [Symbol] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def attribute_class(name)
      label_value(name, object.public_send(name).class)
    end

    # Print inspected attribute value with label
    #
    # @return [undefined]
    #
    # @api private
    #
    def attribute(name)
      label_value(name, object.public_send(name))
    end

    # Print attributes of object
    #
    # @return [undefined]
    #
    # @api private
    #
    def attributes(*names)
      names.each do |name|
        attribute(name)
      end
    end

    # Print name of object
    #
    # @return [undefined]
    #
    # @api private
    #
    def name
      puts(object.class.name)
    end

    # Return string indented with current level
    #
    # @param [String] content
    #
    # @return [String]
    #
    # @api private
    #
    def indented(content)
      "#{indentation_prefix}#{content}"
    end

    # Return indentation prefix
    #
    # @return [String]
    #
    # @api private
    #
    def indentation_prefix
      INDENT * indent_level
    end
    memoize :indentation_prefix

    # Add content to output at current indentation and close line
    #
    # @param [String] content
    #
    # @return [undefined]
    #
    # @api private
    #
    def puts(string)
      output.puts(indented(string))
    end

    # Write content to output at current indentation
    #
    # @param [String] content
    #
    # @return [undefined]
    #
    # @api private
    #
    def write(string)
      output.write(indented(string))
    end

    # Write child label to output at current indentation
    #
    # @param [String] label
    #
    # @return [undefined]
    #
    # @api private
    #
    def child_label(string)
      puts("#{string}:")
    end

    # Call block inside indented context
    #
    # @return [undefined]
    #
    # @api private
    #
    def indent(&block)
      printer = new(object, output, indent_level.succ)
      printer.instance_eval(&block)
    end

    # Return new printer
    #
    # @return [Printer]
    #
    # @api private
    #
    def new(*arguments)
      self.class.new(*arguments)
    end

    # Print label with value
    #
    # @param [String] label
    # @param [Object] value
    #
    # @return [undefined]
    #
    # @api private
    #
    def label_value(label, value)
      write("#{label}: ")
      output.puts(value.inspect)
    end

  end # Printer
end # Morpher
