class ReceiveFile
  require 'thread'
  require 'socket'

  size = 1024*1024*10

  hostname = 'localhost'
  port = 8000

  s = TCPSocket.open(hostname, port)
  puts "connected."

  f = File.open("/Users/Carl-Mac/Desktop/Receiver/output.txt", "w")
  while chunk = s.read(size)
    f.write(chunk)
  end

  s.close
  puts "connection terminated."

end