class DirectoryServer
  require 'thread'
  require 'socket'

  def DirectoryServer.initHash(filesHash, lockHash)
    for dir in ['8001', '8002', '8003']
      print "Scanning #{dir}."
      while Dir.pwd != '/Users/Carl-Mac/RubymineProjects/Distributed File System Project'   #go to root directory
        Dir.chdir '..'
      end

      Dir.chdir dir     #go to directory to be scanned
      files = Dir.glob("*.txt")
      puts " Files #{files.length}."
      for f in files
        if !filesHash[f]      #if there isn't a hash table entry for this file make one
          filesHash[f] = []
        end
        filesHash[f] << dir
      end
    end
  end

  #-------------------------------------------Main starts here!--------------------------------------------

  hostname = 'localhost'
  listenPort = 7000 #ARGV[0]  #Takes in parameter from the bash script/shell
  server = TCPServer.open(listenPort)
  work_q = Queue.new
  filesHash = {}
  lockHash = {}
  fileTokens = {}
  initHash(filesHash, lockHash)      #scan existing storage servers and compile hash of files and locations
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

          if request[0] == 'HELO'
            _, remote_port, _, remote_ip = x.peeraddr #sock_domain, remote_port, remote_hostname, remote_ip = socket.peeraddr
            x.puts req + "IP: #{remote_ip}\nPort: #{remote_port}"
          elsif request[0] == "KILL_SERVICE\n"
            x.puts('ABORT')
            abort('Goodbye')    #shut down server

          elsif request[0] == 'OPEN'
            filename = request[1]
            if !filesHash[filename]   #does the file exist?
              puts "File doesn't exist."
              x.puts "File doesn't exist."
            else
              if lockHash[filename]   #is it already locked?
                puts "File is in use."
                x.puts "File is in use."
              else
                #port = filesHash[filename][rand(0..1)]    #storage servers are ports 8001, 8002, 8003 - pick one at random
                port = filesHash[filename][0]
                lockHash[filename] = true     #lock the file so cannot be used
                token = rand(1000000)
                while fileTokens[token]
                  token = rand(1000000)
                end
                response = "PORT #{port} FILENAME #{port}/#{filename} TOKEN #{token}"     #response client message
                puts response
                x.puts response         #tell client what port to connect to, the pathname and token num
              end
            end

          elsif request[0] == 'CLOSE'
            filename = request[1]
            if !filesHash[filename]     #if file doesn't exist
              #port = filesHash[filename][0]
              port = rand(1..3) + 8000
              #port = 8001
              filesHash[filename] = []
              filesHash[filename] << port
              lockHash[filename] = false     #unlock the file
              token = rand(1000000)
              while fileTokens[token]
                token = rand(1000000)
              end
              response = "PORT #{port} false FILENAME #{filename} TOKEN #{token}"     #response client message
              puts response
              x.puts response
            else
              if !lockHash[filename]     #if the file isn't currently open
                puts "Please open file first."
                x.puts "Please open file first."
              else
                port = filesHash[filename][0]
                if !filesHash[filename][1]
                  repPort = false
                else
                  repPort = filesHash[filename][1]
                end
                x.puts "PORT #{port} #{repPort} FILENAME #{filename}"
              end
            end

          elsif request[0] == "REPLICATE"
            filename = request[1]
            port = request[3]
            if !filesHash[filename].include? port
              filesHash[filename] << port
            end
            puts "Replicated #{filename} on server #{port}"

          elsif request[0] == "LIST"
            x.puts filesHash.keys
            puts "Sent file list."

          else
            puts "Invalid command."
            x.puts "Invalid command."
          end
          x.close
          Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
          puts "Done!"
        end
      }
    end
  end

  #Join threads - executes threads
  workers.each {|worker| worker.join}
  listenThread.join

end