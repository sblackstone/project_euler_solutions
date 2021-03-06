require './primes.rb'

require 'pp'

def concat(i,j)
  return i*10**(Math.log10(j).floor + 1) + j
end

def fast_prime(n)
  return true  if n == 2
  return false if n < 2
  return false if n % 2 == 0 || n % 3 == 0 || n % 5 == 0 || n % 7 == 0
  @base = [31,73]
  d = n-1
  d >>= 1 while d & 1 == 0
  @base.each do |a|
    return true if a == n
    t = d
    y = ModMath.pow(a,t,n)              
    while t != n-1 && y != 1 && y != n-1
      y = (y * y) % n
      t <<= 1
    end
    return false if y != n-1 && t & 1 == 0
  end
  return true
end

def check(i,j)
   fast_prime(concat(i,j)) && fast_prime(concat(j,i))
end

def intersection(hash1,hash2)
  @results = []
  hash1.keys.each do |a|
    @results << a if hash2[a]
  end
  return @results
end

def check_answer(answer, edges)
  n = answer.size - 1
  0.upto(n) do |i|
    (i+1).upto(n) do |j|
      return false unless edges[answer[i]][answer[j]]
    end
  end
  return true
end

N    = 26033
SIZE = 5

Primes.setup(N)

puts "Primes setup complete"

@edges = Hash.new
Primes.primes.each do |p|
  @edges[p] ||= Hash.new(false)
end
num_primes = Primes.primes.size
0.upto(num_primes - 1) do |i|
  p = Primes.primes[i]
  #puts "Checking #{p}"
  (i+1).upto(num_primes - 1) do |j|
    q = Primes.primes[j]
    if check(p,q)
      if @edges[p].keys.size >= SIZE - 2 && @edges[q].keys.size >= SIZE - 2
        @neighborhood = intersection(@edges[p], @edges[q])
        if @neighborhood.size >= SIZE - 2
          @neighborhood.permutation(SIZE - 2).each do |x|
            if check_answer(x, @edges)
              final = x
              final << p
              final << q
              pp final
              pp final.inject(&:+)
              exit
            end
          end
        end
      end
      @edges[p][q] = true
      @edges[q][p] = true
    end
  end
end






