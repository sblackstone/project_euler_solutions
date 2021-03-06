=begin

Arithmetic expressions
Problem 93
By using each of the digits from the set, {1, 2, 3, 4}, exactly once, and making use of the four arithmetic operations (+, −, *, /) and brackets/parentheses, it is possible to form different positive integer targets.

For example,

8 = (4 * (1 + 3)) / 2
14 = 4 * (3 + 1 / 2)
19 = 4 * (2 + 3) − 1
36 = 3 * 4 * (2 + 1)

Note that concatenations of the digits, like 12 + 34, are not allowed.

Using the set, {1, 2, 3, 4}, it is possible to obtain thirty-one different target numbers of which 36 is the maximum, and each of the numbers 1 to 28 can be obtained before encountering the first non-expressible number.

Find the set of four distinct digits, a < b < c < d, for which the longest set of consecutive positive integers, 1 to n, can be obtained, giving your answer as a string: abcd.

=end


require 'pp'

class Frac
  attr_accessor :n, :d
  
  def initialize(n, d = 1)
    @n = n
    @d = d
  end

  def lcm(a,b)
    return a*b / a.gcd(b)
  end

  def simplify
    while @n.gcd(@d) > 1
      g = @n.gcd(@d)
      @n /= g
      @d /= g
    end
    self
  end
  
  def /(other)
    result = Frac.new(self.d, self.n)
    result.n *= other.n
    result.d *= other.d
    result.simplify
  end
  
  def *(other)
    result = Frac.new(self.n, self.d)
    result.n *= other.n
    result.d *= other.d
    result.simplify
  end

  def to_s
    return "(#{@n}/#{d})"
  end
  

  def +(other)
    result = Frac.new(self.n, self.d)
    newd = lcm(@d, other.d)
    result.n = (@n * (newd / @d)) + (other.n * (newd / other.d))
    result.d = newd
    result.simplify
  end

  def -(other)
    result = Frac.new(self.n, self.d)
    newd = lcm(@d, other.d)
    result.n = (@n * (newd / @d)) - (other.n * (newd / other.d))
    result.d = newd
    result.simplify
  end
end




@ops = ['+', '-', '*', '/']


def answer_length(ans)
  ans.sort!
  0.upto(ans.length) do |i|
    return i if ans[i] != i+1
  end
end

def eval_all(exp, h)
  t0 = "exp[0]"
  t1 = "exp[2]"
  t2 = "exp[4]"
  t3 = "exp[6]"
  o1 = exp[1]
  o2 = exp[3]
  o3 = exp[5]
  #pp exp 

  par = [
    "((#{t0} #{o1} #{t1}) #{o2} #{t2}) #{o3} #{t3}", #123
    "(#{t0} #{o1} #{t1}) #{o2} (#{t2} #{o3} #{t3})", #132, 312
    "#{t0} #{o1} (#{t1} #{o2} (#{t2} #{o3} #{t3}))", #321
    "(#{t0} #{o1} (#{t1} #{o2} #{t2})) #{o3} #{t3}",
    "#{t0} #{o1} ((#{t1} #{o2} #{t2}) #{o3} #{t3})",
    
  ]

  par.each do |p|
    v = eval p
    h[v.n] = true if v.n > 0 and v.d == 1
  end
end


def eval_set(set)
  h = Hash.new
  set.map! {|x| Frac.new(x)}
  set.permutation do |p|
    @ops.repeated_combination(3) do |oc|
      oc.permutation do |op|
        exp = p.zip(op).flatten
        exp.delete_at(7)
        eval_all(exp, h)
      end
    end
  end
  return h.keys.sort
end


cur_answer = nil
max_length = 0

1.upto(9) do |a|
  (a+1).upto(9) do |b|
    (b+1).upto(9) do |c|
      (c+1).upto(9) do |d|
        l = answer_length(eval_set([a,b,c,d]))
        puts "#{a}#{b}#{c}#{d}: #{l}"
        if l > max_length
          max_length = l
          cur_answer = "#{a}#{b}#{c}#{d}"
        end
      end
    end
  end
end

pp cur_answer
pp max_length


