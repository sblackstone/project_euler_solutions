=begin
An ant moves on a regular grid of squares that are coloured either black or white.
The ant is always oriented in one of the cardinal directions (left, right, up or down) and moves from square to adjacent square according to the following rules:
- if it is on a black square, it flips the color of the square to white, rotates 90 degrees counterclockwise and moves forward one square.
- if it is on a white square, it flips the color of the square to black, rotates 90 degrees clockwise and moves forward one square.
Starting with a grid that is entirely white, how many squares are black after 1018 moves of the ant?


=end


require 'pp'


class Grid
  
  
  attr_reader :cur, :step_count
  
  def print_board(size)
    (-size).upto(size) do |y|
      print "#{y}\t"
      (-size).upto(size*2) do |x|
        print @black[loc_hsh(x,y)] ? "*" : "."    
      end
      puts    
    
    end
    puts "Steps = #{@step_count}"
  end
  
  
  def initialize
    @black = Hash.new(nil)
    @cur = [0,0]
    @dir = [0,1] # up    
    @step_count = 0
  end
  
  def loc_hsh(x,y)
    "#{x}:#{y}"
  end

  def cur_hsh
    loc_hsh @cur[0], @cur[1]
  end
  
  
  
  def flip_cur
    if cur_white?
      @black[cur_hsh] = 1
    else
      @black.delete cur_hsh
    end     
  end
  
  
  def cur_white?
    @black[cur_hsh].nil?  
  end
  

  def move_forward
    @cur[0] += @dir[0]
    @cur[1] += @dir[1]
  end
  
  
  def turn_left
    @dir = [@dir[1] * -1, @dir[0]]
  end
  
  def turn_right
    @dir = [@dir[1], @dir[0] * -1]
  end

  def step
    if cur_white?
      flip_cur
      turn_left
      move_forward
    else
      flip_cur
      turn_right
      move_forward
    end    
    @step_count += 1  
  end
  
end


g = Grid.new

while true
  g.step
  if g.cur[1] < -23
    system "clear"
    g.print_board(35)
    sleep (6/24.0)
  end
end

=begin
class Euler349
  attr_accessor :black_squares, :loc_x, :loc_y

  def puts_board
    30.downto(-30) do |y|
      (-50).upto(50) do |x|
        if @loc_x == x and @loc_y == y
          print "X"
        else
          print blackSquare?(x,y) ? "#" : "."
        end
      end
      puts
    end    
  end

  def rot_clock
    @dir = (@dir + 1) % 4
  end

  def rot_cclock
    @dir = (@dir - 1) % 4
  end

  def black_square_count
    c = 0
    @black_squares.each do |v|
      c += v.length
    end
    c
  end
  
  def move_forward
    case @dir
    when 0
      @loc_y += 1
    when 1
      @loc_x += 1
    when 2
      @loc_y -= 1
    when 3
      @loc_x -= 1
    end    
  end  
  
  def blackSquare?(x,y)
    @black_squares[x] and @black_squares[x][y]
  end
  
  
  def initialize
    @black_squares = Hash.new(false)
    @loc_x = 0
    @loc_y = 0
    @dir = 0
  end

  def make_move
    if blackSquare?(@loc_x, @loc_y)
      @black_squares[@loc_x].delete(@loc_y)
      if @black_squares[@loc_x].length == 0
        @black_squares.delete(@loc_x)
      end
      rot_cclock
    else
      @black_squares[@loc_x] ||= Hash.new
      @black_squares[@loc_x][@loc_y] = true
      rot_clock
    end
    move_forward  
  end
end

x = Euler349.new

(231).times do |i|
  x.make_move
#  puts puts "\e[H\e[2J" if i > 80
#  x.puts_board if i > 80

end
pp x.loc_x
pp x.loc_y
pp x.black_square_count

=end

