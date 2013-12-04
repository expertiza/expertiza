class AlterResponseType
  #Alter the type column of Responses table
  #Remove the "Map" from the type column
  def self.run!
    puts 'AlterResponseType.run!'
    response = Response.where("type like '%Map'")
    response.each do |response|
      type = response.type[0..-4]
      response.type = type
      response.save validate: false
    end
  end
end