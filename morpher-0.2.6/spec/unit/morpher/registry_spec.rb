describe Morpher::Registry do

  specify do
    klass = Class.new do
      include Morpher::Registry
      register :foo
    end

    expect(klass::REGISTRY).to eql(foo: klass)
  end
end
