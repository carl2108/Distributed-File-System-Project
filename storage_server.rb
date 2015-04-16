class StorageServer
  require 'thread'
  require 'socket'

  hostname = 'localhost'
  #listenPort = ARGV[0]  #Takes in parameter from the bash script/shell - #8001, 8002, 8003 should be used
  listenPort = 8001
  #fileLoc = '/Users/Carl-Mac/Desktop/Ds/' + "#{listenPort}"
  server = TCPServer.open(listenPort)
  work_q = Queue.new
  puts "listening... Port: #{listenPort}"

  #Listening thread - accepts clients and pushes to stack/queue to be processed
  listenThread = Thread.new do
    loop{
      s = server.accept
      work_q.push s
    }
  end

  #Array of 10 worker threads - process clients from the stack/queue
  workers = (0...10).map do
    Thread.new do
      loop{
        x = work_q.pop  #Pop next client to be handled
        Thread.current.thread_variable_set(:busy, 1) #Set thread as busy

        while Thread.current.thread_variable_get(:busy) == 1
          req = x.readline
          requests = req.split(' ')
          puts req

          if req[0, 4] == 'HELO'
            _, remote_port, _, remote_ip = x.peeraddr #sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
            x.puts req + "IP: #{remote_ip}\nPort: #{remote_port}"
          elsif req == "KILL_SERVICE\n"
            x.puts('ABORT')
            abort('Goodbye')    #shut down server

          elsif requests[0] == "OPEN"
            filename = requests[1]
            puts "Opening file: #{filename}"
            f = File.open(filename, 'rb')
            x.write(f.read)
            puts "File sent."
            Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
            x.close

          elsif requests[0] == "CLOSE"
            filename = requests[1]
            f = File.open(filename, "w")
            while data = x.gets
              f.write(data)
            end
            f.close
            puts "File saved."
            Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
            x.close

          else
            puts "Invalid command."
          end
        end
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  listenThread.join
end