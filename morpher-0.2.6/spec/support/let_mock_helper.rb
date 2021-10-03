module LetMockHelper
  def let_mock(name, &block)
    let(name) do
      stubs = block ? instance_exec(double, &block) : {}
      double(name.to_s.capitalize, stubs)
    end
  end
end
