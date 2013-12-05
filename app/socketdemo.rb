require 'socket'      # Sockets are in standard library

hostname = '192.168.1.13'
port = 2012

s = TCPSocket.open(hostname, port)
puts "Message sent to receiver !!"
s.puts("Sender : Connection Established !!")
s.close               # Close the socket when done