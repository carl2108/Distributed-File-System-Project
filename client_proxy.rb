class ClientProxy
  require 'socket'

  localDirectory = "Client/"
  hostname = 'localhost'
  directoryPort = 7000
  tokens = {}
  #s = TCPSocket.open(hostname, port)

  loop{
    print '> '
    command = gets.chomp.split(' ')

    if command[0] == "list"
      s = TCPSocket.open(hostname, directoryPort)
      s.puts "LIST"
      puts s.read
      s.close
    else

      file = command[1]
      if !file
        puts "Invalid argument."
        next
      end
      if !file.end_with? ".txt"     #check to see if client has asked for a txt file
        puts "File server only handles .txt files."
        next
      end

      if command[0] == "open"   #client wants to open file
        s = TCPSocket.open(hostname, directoryPort)
        s.puts "OPEN #{file}"
        response = s.readline
        responses = response.split(' ')
        puts "RESPONSE: #{response}"
        s.close
        if responses[0] == "PORT"
          puts "opening"
          storagePort = responses[1]
          filename = responses[3]
          token = responses[5]
          tokens[file] = token
          s = TCPSocket.open(hostname, storagePort)
          message = "OPEN #{filename}"
          s.puts message
          fileLoc = localDirectory + file
          #puts "FileLoc: #{fileLoc}"
          f = File.open(fileLoc, "w")
          f.write(s.read)
          f.close
          puts "Received file."
        end

      elsif command[0] == "close"       #client wants to close file
        s = TCPSocket.open(hostname, directoryPort)
        s.puts "CLOSE #{file}"
        response = s.readline
        responses = response.split(' ')
        puts response
        s.close
        if responses[0] == "PORT"
          storagePort = responses[1]
          repPort = responses[2]
          filename = responses[4]
          token = tokens[filename]
          tokens.delete(filename)   #delete from hash table
          #puts "StoragePort: #{storagePort}"
          s = TCPSocket.open(hostname, storagePort)
          #puts "Filename: #{filename}"
          message = "CLOSE #{file} TOKEN #{token} REPLICATE #{repPort}"
          puts "Message: #{message}"
          s.puts message
          fileLoc = localDirectory + file
          puts "FileLoc: #{fileLoc}"
          if File.exist?(fileLoc)
            f = File.open(fileLoc, "r")
            s.write(f.read)
            f.close
          end
          s.close
          puts "Sent."

        elsif responses[0] == "REPLICATE"
          port = responses[3]
          s = TCPSocket.open(hostname, port)
          s.puts "#{response} FILE #{file}"   #include token here!
          s.close
          puts "Closed file."
        end
      else
        puts "Invalid command."
      end
    end

  }

end