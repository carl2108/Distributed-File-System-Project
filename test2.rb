class Test2

  fileTok = {}
  fileTok["A"] = []
  fileTok["A"] << 4
  puts fileTok["A"]
  #fileTok.delete("A")
  if fileTok["A"]
    puts true
  else
    puts false
  end
end