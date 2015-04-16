class DirectoryServer
  require 'thread'
  require 'socket'

  def initHash(filesHash)

  end

  def DirectoryServer.createFile(filename, port, hostname, filesHash, lockHash, fileTokens)
    file = "/Users/Carl-Mac/Desktop/Ds/#{port}/#{filename}"
    s = TCPSocket.open(hostname, port)
    message = "CREATE #{file}"
    puts "Message sent: " + message
    filesHash[filename] = []
    filesHash[filename] << port
    lockHash[filename] = []
    lockHash[filename] << false
    fileTokens[filename] = []
    s.puts message
    s.close
  end

  #-------------------------------------------Main starts here!--------------------------------------------

  fileLoc = '/Users/Carl-Mac/Desktop/Ds/'
  hostname = 'localhost'
  listenPort = 7000 #ARGV[0]  #Takes in parameter from the bash script/shell
  server = TCPServer.open(listenPort)
  work_q = Queue.new
  filesHash = {}
  lockHash = {}
  fileTokens = {}
  #initHash(filesHash)      #scan existing storage servers and compile hash of files and locations
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
          puts req
          request = req.split(' ')

          if req[0, 4] == 'HELO'
            _, remote_port, _, remote_ip = x.peeraddr #sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
            x.puts req + "IP: #{remote_ip}\nPort: #{remote_port}"
          elsif req == "KILL_SERVICE\n"
            x.puts('ABORT')
            abort('Goodbye')    #shut down server

          elsif request[0] == 'OPEN'
            filename = request[1]
            begin
              if(lockHash[filename] == true)    #if file is in use - break
                puts "This file is currently in use. Please try again later."
                x.puts "This file is currently in use. Please try again later."
                Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
                x.close
                break
              end

              #port = filesHash[filename][rand(0..1)]    #storage servers are ports 8001, 8002, 8003 - pick one at random
              port = filesHash[filename][0]
              lockHash[filename] = true     #lock the file so cannot be used
              loc = fileLoc + "#{port}/" + filename      #file path name
              response = "PORT #{port} FILENAME #{loc}"       #response client message
              x.puts response                                           #tell client what port to connect to and the pathname
              puts "Responded: #{response}"
              x.close
              Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy

            rescue      #file doesn't exist - can't open
              puts "File doesn't exist."
              x.puts "File doesn't exist."
              Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
              x.close
            end

          elsif request[0] == 'CLOSE'
            filename = request[1]
            begin
              if(lockHash[filename] == false)    #if file is in use - break
                puts "This file is currently in use. Please try again later."
                x.puts "NACK"
                Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
                x.close
                break
              end

              #port = filesHash[filename][rand(0..1)]    #storage servers are ports 8001, 8002, 8003 - pick one at random
              port = filesHash[filename][0]
              lockHash[filename] = true     #lock the file so cannot be used
              loc = fileLoc + "#{port}/" + filename      #file path name
              response = "PORT #{port} FILENAME #{loc}"       #response client message
              x.puts response                                           #tell client what port to connect to and the pathname
              puts "Responded: #{response}"
              x.close
              Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy

            rescue      #file doesn't exist
              puts "File doesn't exist. Creating."
              x.puts "File created."
              #port = rand(1..3) + 8000
              port = 8001
              createFile(filename, port, hostname, filesHash, lockHash, fileTokens)
              puts "Created file: " + filename
              Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
              x.close
            end
          end
        end
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  listenThread.join

end