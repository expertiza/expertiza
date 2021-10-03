require 'morpher'

extend Morpher::NodeHelpers

class Input
  include Anima.new(:foo)
end # Input

node =
  s(:block,
    s(:guard, s(:primitive, Hash)),
    s(:hash_transform,
      s(:key_symbolize, :foo,
        s(:guard,
          s(:or,
            s(:primitive, String),
            s(:primitive, NilClass)
          )
        )
      )
    ),
    s(:load_attribute_hash, s(:param, Input))
  )

EVALUATOR = Morpher.compile(node)
