module Morpher
  class Compiler
    class Evaluator
      # Emitter for evaluators
      class Emitter < Compiler::Emitter
        include Registry, Concord.new(:compiler, :evaluator_klass, :node)

        # Return output
        #
        # @return [Evaluator]
        #
        # @api private
        #
        def output
          validate_node
          evaluator
        end
        memoize :output

        # Validate node
        #
        # @return [undefined]
        #   if successful
        #
        # @raise [Error]
        #   otherwise
        #
        # @api private
        #
        abstract_method :validate_node
        private :validate_node

        # Return evaluator
        #
        # @return [Evaluator]
        #
        # @api private
        #
        abstract_method :evaluator
        private :evaluator

        # Emitter for nullary non parameterized evaluators
        class Nullary < self
          register Morpher::Evaluator::Nullary

        private

          # Return output
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def evaluator
            evaluator_klass.new
          end

          # Validate node
          #
          # @return [undefined]
          #   if successful
          #
          # @raise [Error]
          #   otherwise
          #
          # @api private
          #
          def validate_node
            assert_children_amount(0)
          end

          # Emitter for nullary parameterized evaluators
          class Parameterized < self
            register Morpher::Evaluator::Nullary::Parameterized

            children :param

          private

            # Return output
            #
            # @return [Evaluator]
            #
            # @api private
            #
            def evaluator
              evaluator_klass.new(effective_param)
            end

            # Return effective param
            #
            # @return [Object]
            #
            # @api private
            #
            def effective_param
              if param.kind_of?(AST::Node) && param.type.equal?(:raw) && param.children.length.equal?(1)
                param.children.first
              else
                param
              end
            end

            # Validate node
            #
            # @return [undefined]
            #   if successful
            #
            # @raise [Error]
            #   otherwise
            #
            # @api private
            #
            def validate_node
              assert_children_amount(1)
            end

          end # Paramterized
        end # Nullary

        # Emitter for unary evaluators
        class Unary < self
          register Morpher::Evaluator::Unary
          children :operand

        private

          # Return evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def evaluator
            evaluator_klass.new(compiler.call(operand))
          end

          # Validate node
          #
          # @return [undefined]
          #   if successful
          #
          # @raise [Error]
          #   otherwise
          #
          # @api private
          #
          def validate_node
            assert_children_amount(1)
          end

        end # Unary

        # Emitter for unary evaluators
        class Binary < self
          register Morpher::Evaluator::Binary
          children :left, :right

        private

          # Return evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def evaluator
            evaluator_klass.new(
              compiler.call(left),
              compiler.call(right)
            )
          end

          # Validate node
          #
          # @return [undefined]
          #   if successful
          #
          # @raise [Error]
          #   otherwise
          #
          # @api private
          #
          def validate_node
            assert_children_amount(2)
          end

        end # Unary

        # Emitter for nary evaluators
        class Nary < self
          register Morpher::Evaluator::Nary

        private

          # Return evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def evaluator
            evaluator_klass.new(children.map(&compiler.method(:call)))
          end

          # Validate node
          #
          # @return [undefined]
          #   if successful
          #
          # @raise [Error]
          #   otherwise
          #
          # @api private
          #
          def validate_node
          end

        end # Nary

      end # Emitter
    end # Evaluator
  end # Compiler
end # Morpher
