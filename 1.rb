@sum = 0
1.upto(999) do |x|
	if x % 3 == 0 or x % 5 == 0
		@sum = @sum + x
	end
end
puts @sum
