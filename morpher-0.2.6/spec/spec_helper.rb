require 'devtools/spec_helper'
require 'morpher'
require 'mutant' # for the node helpers

# Monkeypatch to mutant all specs per mutation.
#
# TODO: Use master once it supports configurable implicit coverage.
#
# Morpher predicates are needed to finally make this configurable in mutant.
#
module Mutant

  module Rspec
    class Killer

      # Return all example groups
      #
      # @return [Enumerable<RSpec::Example>]
      #
      # @api private
      #
      def example_groups
        strategy.example_groups
      end

    end # Rspec
  end # Killer
end # Mutant

RSpec.configure do |config|
  config.include(StripHelper)
  config.include(Morpher::NodeHelpers)
  config.expect_with :rspec do |rspec|
    rspec.syntax = %i[expect should]
  end
end
