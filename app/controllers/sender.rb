require 'socket'
class Sender
  #Simple test
  #require 'socket'
  #hostname='localhost'
  #port=2000
  #s=TCPsocket.open(hostname,port)
  #while line=s.gets
    #puts line.chomp
  #end
  #s.close


  #establish connection
  #send a quick message
  #wait for messages from the server
  #if one of the messages contains 'Goodbye' we'll disconnect
  #end loop
  hostname = '192.168.1.13'
  port = 2012
  clientSession = TCPSocket.new(hostname, port)  #tell the client where to connect
  puts "log: starting connection"
  puts "log: saying hello"
  clientSession.puts "Sender: Hello Server World!\n"
  puts clientSession.recv(100)
  #make sure that the session isn't closed, spit out any message the server has to say,
  #and check to se if any of those messages contain 'Goodbye'. If they do we can close the connection.
#  while !(clientSession.closed?) || (serverMessage = clientSession.gets)
#   if serverMessage.include?("Goodbye")
#     puts "log: closing connection"
      clientSession.close
#    end
#  end
end
