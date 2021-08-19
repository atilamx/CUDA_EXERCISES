fda = File.new('matrix_A','w')
fdb = File.new('matrix_B','w')

puts "Array size?"
size = gets
size.chomp!

for i in 0..(size.to_i - 1)
  for i in 0..(size.to_i - 1)	
    r = rand(1..6)	  

    #print "#{r}"
    fda.write("#{r}")
  end   
  #puts " "
  fda.write "\n"
end	

for i in 0..(size.to_i - 1)
  for i in 0..(size.to_i - 1)
    r = rand(1..6)

    #print "#{r}"
    fdb.write("#{r}")
  end
  #puts " "
  fdb.write "\n"
end

fda.flush
fdb.flush

fda.close
fdb.close

