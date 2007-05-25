class Login
  attr_accessor :errors
  attr_accessor :name, :password

  def initialize
    @errors = Array.new
  end

end
  
