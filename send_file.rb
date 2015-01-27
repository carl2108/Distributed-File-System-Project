class SendFile
  require 'thread'
  require 'socket'

  size = 1024*1024*10

  port = 8000
  hostname = 'localhost'
  server = TCPServer.open(port)
  puts "listening..."

  s = server.accept
  puts "connected."

  f = File.open('/Users/Carl-Mac/Desktop/Sender/Untitled.txt', 'rb')
  while chunk = f.read(size)
    s.write(chunk)
  end

  puts "finished sending."

  s.close

  puts "connection terminated..."

end