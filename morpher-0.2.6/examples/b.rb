require 'morpher'

extend Morpher::NodeHelpers

class Address
  include Anima.new(:street)
end

class Person
  include Anima.new(:address)
end

node = s(:block,
  s(:guard, s(:primitive, Hash)),
  s(:hash_transform,
    s(:key_symbolize, 'street',
      s(:guard, s(:primitive, String))
    )
  ),
  s(:load_attribute_hash, s(:param, Address))
)

ADDRESS_EVALUATOR = Morpher.compile(node)

node = s(:block,
  s(:guard, s(:primitive, Hash)),
  s(:hash_transform,
    s(:key_symbolize, 'address',
      ADDRESS_EVALUATOR.node
    )
  ),
  s(:load_attribute_hash, s(:param, Person))
)

PERSON_EVALUATOR = Morpher.compile(node)
