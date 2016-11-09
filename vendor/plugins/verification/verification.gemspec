$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "verification"
  s.version     = "1.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Heinemeier Hansson"]
  s.email       = ["david@loudthinking.com"]
  s.homepage    = "https://rubygems.org/gems/verification"
  s.summary     = %q{Verify preconditions for Rails actions}
  s.description = %q{Verify preconditions for Rails actions}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activesupport', '>= 3.0.0', '< 5.0')
  s.add_dependency('actionpack', '>= 3.0.0', '< 5.0')

  s.add_development_dependency('rake')
  s.add_development_dependency('test-unit', '~> 2.5.5')
  s.add_development_dependency('mocha', "1.0.0.alpha")
end
