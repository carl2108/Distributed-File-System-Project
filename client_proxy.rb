class ClientProxy
  require 'socket'

  localDirectory = "/Users/Carl-Mac/Desktop/Ds/Client/"
  hostname = 'localhost'
  directoryPort = 7000
  #s = TCPSocket.open(hostname, port)

  loop{
    print '> '
    command = gets.chomp.split(' ')

    if command[0] == "open"   #client wants to open file
      file = command[1]
      s = TCPSocket.open(hostname, directoryPort)
      s.puts "OPEN #{file}"
      response = s.readline
      responses = response.split(' ')
      puts "RESPONSE: #{response}"
      s.close
      if responses[0] == "PORT"
        puts "opening"
        storagePort = responses[1]
        #puts "StoragePort: #{storagePort}"
        s = TCPSocket.open(hostname, storagePort)
        filename = responses[3]
        #puts "Filename: #{filename}"
        message = "OPEN #{filename}"
        #puts "Message: #{message}"
        s.puts message
        fileLoc = localDirectory + file
        #puts "FileLoc: #{fileLoc}"
        f = File.open(fileLoc, "w")
        f.write(s.read)
        f.close
        puts "Received file."
      end

    elsif command[0] == "close"       #client wants to close file
      filename = command[1]
      s = TCPSocket.open(hostname, directoryPort)
      s.puts "CLOSE #{file}"
      response = s.readline
      responses = response.split(' ')
      puts response
      s.close
      if response[0] == "PORT"
        storagePort = response[1]
        #puts "StoragePort: #{storagePort}"
        s = TCPSocket.open(hostname, storagePort)
        filename = response[3]
        #puts "Filename: #{filename}"
        message = "CLOSE #{file}"
        puts "Message: #{message}"
        s.puts message
        fileLoc = localDirectory + file
        puts "FileLoc: #{fileLoc}"
        f = File.open(fileLoc, "w")
        s.write(f.read)
        f.close
        puts "Received file."
      end

      #port = filesHash[filename][rand(0..1)]    #storage servers are ports 8001, 8002, 8003 - pick one at random
      lockHash[filename] = true     #lock the file so cannot be used
      loc = fileLoc + "#{port}/" + filename      #file path name
      response = "PORT #{port} FILENAME #{loc}"       #response client message
      x.puts response                                           #tell client what port to connect to and the pathname
      x.close
      Thread.current.thread_variable_set(:busy, 0) #Set thread as not busy
    else
      puts "Invalid command."
    end

  }

end