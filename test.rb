class Test
  require 'socket'

  # h = {}
  # h["A"] = [3]
  # h["A"] << 4
  # begin
  #   puts h["B"][rand(0..1)]
  #
  # rescue
  #   puts "No such file"
  #
  # end

  # loc = 'hello'
  # port = 90
  # loc1 = loc + " #{port}"
  # puts loc1

  # ans = gets.chomp
  # while ans != "y" && ans != "n"
  #   puts "Invalid response. Would you like to create ? [y/n]"
  #   ans = gets.chomp
  # end

  hostname = 'localhost'
  storagePort = 8001
  directoryPort = 7000

  loop{
    s = TCPSocket.open(hostname, directoryPort)
    print "> "
    x = gets.chomp
    s.puts x
  }

end