require 'devtools'
Devtools.init_rake_tasks

Rake.application.load_imports
task('metrics:mutant').clear
namespace :metrics do
  task mutant: :coverage do
    success = Kernel.system(*%w[
      bundle exec mutant
      --zombie
      --use rspec
      --include lib
      --require morpher
      --since HEAD~1
      --
      Morpher*
    ]) or fail 'Mutant task is not successful'
  end
end

# NOTICE: This uses private interface of morpher that can change at any time.
# Its just a placeholder for a better reflection technique!!!
namespace :morpher do
  desc 'List morpher nodes'
  task :list do

    class Presenter

      class Evaluator < self
        include Concord::Public.new(:name, :evaluator)

        def arity
          emitter = Morpher::Compiler::Evaluator::DEFAULT.send(:emitter, evaluator)
          emitter_ns = Morpher::Compiler::Evaluator::Emitter

          {
            emitter_ns::Nullary => :nullary,
            emitter_ns::Nullary::Parameterized => :nullary_param,
            emitter_ns::Unary => :unary,
            emitter_ns::Binary => :binary,
            emitter_ns::Nary => :nary
          }.fetch(emitter)
        end

        def transitivity
          ancestors = evaluator.ancestors
          if ancestors.include?(Morpher::Evaluator::Transformer::Transitive)
            :yes
          elsif ancestors.include?(Morpher::Evaluator::Transformer::Intransitive)
            :no
          else
            :dynamic
          end
        end

        def role
          if evaluator.ancestors.include?(Morpher::Evaluator::Transformer)
            :transforming
          else
            :predicate
          end
        end

      end

      class Preprocessor
        include Concord::Public.new(:name, :emitter)

        def children_nodes
          emitter.allocate.send(:named_children).join(', ')
        end
      end

    end

    puts 'Evaluators:'
    EVALUATOR_FIELDS = [:name, :arity, :transitivity, :role]
    EVALUATOR_FORMAT = '%-24s - %-15s - %-15s - %-20s'.freeze

    puts EVALUATOR_FORMAT % EVALUATOR_FIELDS
    Morpher::Evaluator::REGISTRY.each do |name, evaluator|
      presenter = Presenter::Evaluator.new(name, evaluator)
      puts EVALUATOR_FORMAT % EVALUATOR_FIELDS.map(&presenter.method(:public_send))
    end

    puts 'Preprocessors:'
    PREPROCESSOR_FORMAT = '%-20s - %-20s'
    PREPROCESSOR_FIELDS = [:name, :children_nodes]
    puts PREPROCESSOR_FORMAT % PREPROCESSOR_FIELDS
    Morpher::Compiler::Preprocessor::Emitter::REGISTRY.each do |name, emitter|
      presenter = Presenter::Preprocessor.new(name, emitter)
      puts PREPROCESSOR_FORMAT % PREPROCESSOR_FIELDS.map(&presenter.method(:public_send))
    end
  end
end
