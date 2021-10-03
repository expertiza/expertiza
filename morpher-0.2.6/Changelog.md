# v0.2.3 2014-04-22

[Compare v0.2.2..v0.2.3](https://github.com/mbj/morpher/compare/v0.2.2...v0.2.3)

Changes:

* Dependency updates.

# v0.2.2 2014-04-10

[Compare v0.2.1..v0.2.2](https://github.com/mbj/morpher/compare/v0.2.1...v0.2.2)

Changes: 

* Add Mutant.sexp returning a morpher AST node via evaluating a block with sexp node API available.
* Add Mutant.build returning a morpher evaluator via evaluating a block with sexp node API available.
* Fix evaluation errors on Transformer::Map node.
* Ensure mutant coverage scores on CI

# v0.2.1 2014-03-29

[Compare v0.2.0..v0.2.1](https://github.com/mbj/morpher/compare/v0.2.0...v0.2.1)

Changes: 

* Fix warnings on multiple method definition

# v0.2.0 2014-03-09

[Compare v0.1.0..v0.2.0](https://github.com/mbj/morpher/compare/v0.1.0...v0.2.0)

Changes:

* Add param node s(:param, Model, :some, :attributes) to build Transformer::Domain::Param

Breaking-Changes:

* Rename {load,dump}_attributes_hash to {load,dump}_attribute_hash
* Require {load,dump}_attribute_hash param to be an instance of Transformer::Domain::Param

# v0.1.0 2014-03-08

[Compare v0.0.1..v0.1.0](https://github.com/mbj/morpher/compare/v0.0.1...v0.1.0)

Breaking-Changes:

* Renamed `Morpher.evaluator(node)` to `Morpher.compile(node)`
* Rename node: `symbolize_key` to `key_symbolize`
* Rename node: `anima_load` to `load_attributes_hash`
* Rename node: `anima_dump` to `dump_attributes_hash`
* The ability to rescue/report anima specific exceptions has been dropped

Changes:

* Add {dump,load}_{attribute_accessors,instance_variables} as additional strategies to
  transform from / to domain objects.

# v0.0.1 2014-03-02

First public release.
