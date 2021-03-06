require 'pp'


class Node
  attr_accessor :up, :down, :left, :right, :desc, :col_node, :vaporized, :covered, :matrix, :hidden, :row_num, :col_num, :vaporized
  def initialize(desc,matrix)
    @desc = desc
    @up = nil
    @down = nil
    @left = nil
    @right = nil
    @col_node = nil
    @row_num = nil
    @col_num = nil
    @vaporized = false
    @covered = false
    @hidden = false
    @matrix = matrix
  end
  def to_s
    @desc
  end

  def hide
    #puts "Hiding  #{self.desc}"
    if self.hidden
      throw new Exception("already hidden")
    end
    self.down.up = self.up
    self.up.down = self.down
    self.hidden = true
    self.col_node.count -= 1
  end
  
  def unhide
    #puts "Unhiding  #{self.desc}"
    self.down.up = self
    self.up.down = self
    self.hidden = false
    self.col_node.count += 1
  end
  

  def vaporize
    self.up.down    = self.down
    self.down.up    = self.up
    self.left.right = self.right
    self.right.left = self.left
    self.col_node.count = 0
    self.vaporized  = true
  end
  
  def unselect
    j = self.left
    while j != self
      j.col_node.uncover
      j = j.left
    end
  end
  
  def select
    j = self.right
    while j != self
      j.col_node.cover
      j = j.right
    end
  end
  
  
  def d
    return 'VV ' if self.vaporized
    return 'CC ' if self.covered
    return 'CC ' if self.col_node.covered
    return 'HH ' if self.hidden
    return "#{self.desc} " if self.desc > 9
    return "0#{self.desc} " 

  end
  
end

class ColumnHeader < Node
  attr_accessor :count

  def cover
    #puts "Covering #{self.desc}"
    if self.covered
      throw "can't re-cover #{self.desc}"
    end
    self.left.right = self.right
    self.right.left = self.left
    self.covered = true
    i = self.down
    while i != self
      j = i.right
      while j != i
        j.hide
        j = j.right
      end
      i = i.down
    end
  end
  
  def uncover
    #puts "Uncovering #{self.desc}"
    i = self.up
    while i != self
      j = i.left
      while j != i
        j.unhide
        j = j.left
      end
      i = i.up
    end
    self.left.right = self
    self.right.left = self
    self.covered = false
  end
  
  def initialize(desc,matrix)
    @count = -1
    super(desc,matrix)
  end
  
end


class MatrixX
  attr_accessor :matrix, :entry, :solution

  def create_header
    @entry = ColumnHeader.new('ENTRY', self);
    cur = @entry
    0.upto(@constraints-1) do |i|
      cur.right = ColumnHeader.new("C#{i}",self)
      cur.right.left = cur
      cur = cur.right
    end
    @entry.left = cur
    cur.right = @entry
    cur = @entry
  end
  

  def create_nodes
    @matrix = Array.new(@rows)
    @matrix[0] = Array.new(@constraints)
    create_header

    0.upto(@rows-1) do |i|
      @matrix[i] = Array.new(@constraints)
      0.upto(@constraints-1) do |j|
        @matrix[i][j] = Node.new(i*9 + j, self)
        @matrix[i][j].row_num = i
        @matrix[i][j].col_num = j
      end
    end
  end
  
  def link_nodes
    0.upto(@rows-1) do |y|
      0.upto(@constraints-1) do |x|
        @matrix[y][x].hidden = false
        @matrix[y][x].covered = false
        @matrix[y][x].vaporized = false
        @matrix[y][x].down  = @matrix[(y+1) % @rows][x]
        @matrix[y][x].up    = @matrix[(y-1) % @rows][x]
        @matrix[y][x].left  = @matrix[y][(x-1) % @constraints]
        @matrix[y][x].right = @matrix[y][(x+1) % @constraints]
      end
    end                  
    cur = @entry.right
    0.upto(@constraints-1) do |i|
      @matrix[0][i].up = cur
      cur.down = @matrix[0][i]

      @matrix[@rows-1][i].down = cur
      cur.up = @matrix[@rows-1][i]
      0.upto(@rows - 1) do |j|
        @matrix[j][i].col_node = cur
      end
      cur = cur.right
    end
    
  end
  
  def apply_state(state)
    0.upto(@rows-1) do |r|
      0.upto(@constraints-1) do |c|
        if state[r][c] == 0
          @matrix[r][c].vaporize
        end
      end
    end
  end
  
  def output
    puts
    cur = @entry.right
    while cur != @entry
      print "#{cur.desc}  "
      cur = cur.right
    end    
    0.upto(@rows-1) do |r|
      puts
      0.upto(@constraints-1) do |c|
        print @matrix[r][c].d
        print " "
      end
    end
    puts
    puts "*" * 25
    puts
  end
  
  def solve(k)
    @solution = Array.new if k == 0
    if self.entry.right == self.entry
      return @solution
    end
    best = self.entry.right
    col = best.right
    while col != self.entry
      if col.count < best.count
        best = col
      end
      col = col.right
    end
    col = best

    col.cover
    #puts "Attempting to fulfill #{col.desc}"
    r = col.down
    while r != col
      #puts "Selecting #{r.desc}"
      @solution[k] = r
      r.select
      #self.output
      answer = self.solve(k+1)
      return answer if answer
      @solution.pop
      r.unselect
      r = r.down
    end
    col.uncover
    return false
  end
  

  def initialize(constraints, rows)
    @constraints = constraints
    @rows = rows
    @solution = []
    create_nodes
    link_nodes
  end
end

=begin
m = MatrixX.new(7,6)

s = Array.new(6)
0.upto(4) do |i|
  s[i] = Array.new(5)
  0.upto(4) {|j| s[i][j] = rand(2)}
end

s = 
[
  
[1,0,0,1,0,0,1],
[1,0,0,1,0,0,0],
[0,0,0,1,1,0,1],
[0,0,1,0,1,1,0],
[0,1,1,0,0,1,1],
[0,1,0,0,0,0,1]  
  
]

pp s
m.apply_state(s)
m.output

sol = m.solve(0)
if sol
  sol.each {|x| puts x.row_num }
else
  puts "No Answer"
end
#puts m.entry.right.desc


=end
BOX_MAP = [  0,0,0,1,1,1,2,2,2,
             0,0,0,1,1,1,2,2,2,
             0,0,0,1,1,1,2,2,2,
             3,3,3,4,4,4,5,5,5,
             3,3,3,4,4,4,5,5,5,
             3,3,3,4,4,4,5,5,5,
             6,6,6,7,7,7,8,8,8,
             6,6,6,7,7,7,8,8,8,
             6,6,6,7,7,7,8,8,8
          ]

ROW_MAP = [ 0,0,0,0,0,0,0,0,0,
            1,1,1,1,1,1,1,1,1,
            2,2,2,2,2,2,2,2,2,
            3,3,3,3,3,3,3,3,3,
            4,4,4,4,4,4,4,4,4,
            5,5,5,5,5,5,5,5,5,
            6,6,6,6,6,6,6,6,6,
            7,7,7,7,7,7,7,7,7,
            8,8,8,8,8,8,8,8,8
          ]

COL_MAP = [
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8,  
            0,1,2,3,4,5,6,7,8
]


#               81  81  81  81
# constraints: SQU ROW COL BOX
#
# SQU - 0 to 80
# ROW - 81 to 161
# COL - 162 to 242
# BOX - 243 to 323
#
# rows: value in box...
#  0:1
#  0:2
#  0:3

@puzzles = []
f = File.open("sudoku.txt")
0.upto(49) do |puzzle|
  name = f.gets.strip
  puz = ""
  0.upto(8) do |i|
    puz += f.gets.strip
  end  
  @puzzles << puz.split("").map(&:to_i)
end

s = Array.new(729)
0.upto(728) do |i|
  s[i] = Array.new(324,0)
end

0.upto(80) do |box|
  1.upto(9) do |val|
    row = box*9 + (val-1)
    s[row][box] = 1
    s[row][80  + ROW_MAP[box]*9 + val] = 1    
    s[row][161 + COL_MAP[box]*9 + val] = 1    
    s[row][242 + BOX_MAP[box]*9 + val] = 1    
  end
end


=begin
Grid 01
003020600
900305001
001806400
008102900
700000008
006708200
002609500
800203009
005010300

4 8 3 9 2 1 6 5 7
9 6 7 3 4 5 8 2 1
2 5 1	8 7 6 4 9 3


=end


m = MatrixX.new(324, 729)
@sum = 0
0.upto(49) do |puz|

  m.create_header
  m.link_nodes
  m.apply_state(s)


  puts "Applying initial state"

  0.upto(80) do |box|
    1.upto(9) do |val|
      row = box*9 + (val-1)
      if @puzzles[puz][box] == val 
        #puts "Row #{row} covers #{val} in box #{box}"
        m.solution.push(m.matrix[row][box])
        m.matrix[row][box].col_node.cover
        m.matrix[row][box].select
      end
    end
  end

  puts "Beginning solve"

  #m.output
  sol = m.solve(0)
  sol.map! {|x| x.row_num }
  0.upto(80) do |box|
    1.upto(9) do |val|
      row = box*9 + (val-1)
      if sol.include?(row)
        @puzzles[puz][box] = val
      end
    end
  end

  @sum += @puzzles[puz][0]*100
  @sum += @puzzles[puz][1]*10
  @sum += @puzzles[puz][2] 



end
puts @sum
exit

=begin
m.apply_state(state)
m.output
t = m.entry.right.down
t.col_node.cover
t.select
m.output
t.unselect
t.col_node.uncover
m.output
=end

=begin
m = MatrixX.new(state.first.length, state.length)
m.apply_state(state)
pp m.solve(0)
exit
=end

=begin
Grid 00
483921657
960345821
251076493
548132076
729564038
136098245
372689514
814250769
695417382

exit


state2 = [
[1,0,0,1,0,0,1],
[1,0,0,1,0,0,0],
[0,0,0,1,1,0,1],  
[0,0,1,0,1,1,0],
[0,0,1,0,0,1,1],
[0,1,0,0,0,0,1]
]

=end
