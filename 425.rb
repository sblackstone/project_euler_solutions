=begin
Two positive numbers A and B are said to be connected (denoted by "A ↔ B") if one of these conditions holds:
(1) A and B have the same length and differ in exactly one digit; for example, 123 ↔ 173.
(2) Adding one digit to the left of A (or B) makes B (or A); for example, 23 ↔ 223 and 123 ↔ 23.

We call a prime P a 2's relative if there exists a chain of connected primes between 2 and P and no prime in the chain exceeds P.

For example, 127 is a 2's relative. One of the possible chains is shown below:
2 ↔ 3 ↔ 13 ↔ 113 ↔ 103 ↔ 107 ↔ 127
However, 11 and 103 are not 2's relatives.

Let F(N) be the sum of the primes ≤ N which are not 2's relatives.
We can verify that F(103) = 431 and F(104) = 78728.

Find F(107).
=end

require './euler_lib.rb'

@h = HandySieve.fetch(6)

@digit_store = Hash.new(nil)

def digits(n)
  return @digit_store[n] ||= Math.log10(n).floor + 1
end

def kth_digit(n,k)
  ((n % 10**(k+1)) - (n % 10**k)) / 10**k
end


def digit_to_left(n, &proc)
  1.upto(9) do |a|
    yield a*10**digits(n) + n
  end
end




def change_digit_k(n, k, &proc)
  digit_k = kth_digit(n,k)
  
  start = (k == digits(n) - 1) ? 1 : 0
  
  start.upto(9) do |nd|
    yield n + (nd-digit_k) * 10**k
  end
end



def change_1_digit(n, &proc)
  0.upto(digits(n)-1) do |digit|
    change_digit_k(n, digit, &proc)
  end
end

def directly_connected(n, &proc)
  digit_to_left(n, &proc)
  change_1_digit(n, &proc)
end




def search(n, seen = Hash.new, &proc)
  puts n
  return if seen[n]
  seen[n] = true
  return if n > 10**3
  yield n if @h.prime?(n)
  directly_connected(n) do |k|
    search(k, seen, &proc)
  end  
end

sum = 0

@h.primes_upto(10**3) do |p|
  sum += p
end


search(2) do |n|
  sum -= n
end


puts sum
  



#directly_connected(2) do |k|
#  puts k
#end




=begin
require 'pp'

@max_prime = 10**5

f = File.open("primes_to_10_7.txt")

@primes = Array.new
@prime_map = Hash.new(false)
@primes_by_len = Array.new(25)
0.upto(25) do |i|
  @primes_by_len[i] = Hash.new(false)
end


@digit_store = Hash.new(nil)
def digits(n)
  return @digit_store[n] ||= Math.log10(n).floor + 1
end

def off_by_one(a,b)
  diff = (a - b).abs
  return false if diff == 0
  while (diff % 10 == 0) do
    diff /= 10
  end
  diff = diff - (diff % 10)
  return diff == 0
end

while (line = f.gets) do
  line.strip!
  num = line.to_i
  break if num > @max_prime
  @primes_by_len[line.size][num] = true
  @primes.push(num)
  @prime_map[num] = true  
end


def connected_to(n) 
  @result = Array.new
  @primes_by_len[digits(n)].keys.each do |i|
    @result.push(i) if off_by_one(i,n)
  end
  ten_n = n *10
  [1,3,5,9].each do |i|
    @result.push(ten_n + i) if @prime_map[ten_n + i]
  end
  addon = 10**(digits(n))
  1.upto(9) do |i|
    @result.push(n + addon*i) if @prime_map[n + addon*i]
  end  
  @result
end


pp connected_to(133)
@search_space = Hash.new(nil)
@search_space[2] = 0

while true
  @disco = Array.new
  @search_space.each do |k,v|
    if v == 0
      #puts "Processing #{k}"
      @search_space[k] = connected_to(k) 
      @search_space[k].each do |d|
        @disco.push d unless @search_space[d]
      end
      
    end
  end
  break if @disco.length == 0
  pp @disco.length
  @disco.each do |d|
    @search_space[d] ||= 0
  end
end  
pp @disco
pp @search_space

=end