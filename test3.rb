def z_comp(b,c)
  val = 0
  1.upto(10000000) do |n|
    val = val + Math.sin(Math.log(n)*c)
  end
  return val
end

puts z_comp(10,14.13472514173469379045725198356247027078425711569924317568556746014996342980925676494901039317156101277920297154879743676614269146988225458250536323)