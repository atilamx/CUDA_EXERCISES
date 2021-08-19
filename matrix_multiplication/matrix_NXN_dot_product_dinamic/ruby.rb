a = []
b = []
c = []

a = Array.new( 100, Array.new(100, 0) )
b = Array.new( 100, Array.new(100, 0) )

def fill_array(array)
  for i in 0..3 
    for j in 0..3
      array[i][j] = rand()
    end	  
  end	
end

def print_arr(array)
  puts "["	
  for i in 0..3
    print "{" 
    for j in 0..3
      print "#{array[i][j]}," 
    end
    puts "}"
  end
  puts "]"	
end

def multiply_array(a,b)
    
end	

fill_array(a)
fill_array(b)

print_arr(a)
print_arr(b)

multiply_array()

